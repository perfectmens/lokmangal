#!/usr/bin/env python3
"""
Auraliss - Corelife Wholefoods Industrial Telemetry Simulation Server
Simulates industrial PLC/SCADA signals, load cells, powder maker state machine,
revolving event ticker, energy metrics, and alarm lifecycle management.
Listens on 0.0.0.0:8000 (accessible locally and over LAN / Internet tunnels).
"""

import asyncio
import time
import random
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

app = FastAPI(
    title="Auraliss - Corelife Wholefoods Telemetry Engine",
    description="Industrial Telemetry and SCADA Simulation API",
    version="1.1.0"
)

# Enable CORS for mobile app, web admin, and remote network clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==============================================================================
# INDUSTRIAL SIMULATION STATE
# ==============================================================================

POWDER_MAKER_STATES = [
    {"state": "SYSTEM_READY", "display": "System Ready", "duration": 15},
    {"state": "MIXING", "display": "Mixing", "duration": 20},
    {"state": "CRYSTALLIZATION", "display": "Crystallization", "duration": 25},
    {"state": "POWDER_MAKING", "display": "Powder Making", "duration": 40},
    {"state": "DISCHARGE", "display": "Discharge", "duration": 15},
]

class PlantSimulationState:
    def __init__(self):
        self.plant_id = "CORELIFE-01"
        self.name = "Corelife Wholefoods"
        self.location = "Jaggery & Liquid Sugars Facility"
        self.business_units = ["Jaggery", "Liquid Sugars"]
        self.is_online = True

        # Powder Maker State Machine
        self.state_idx = 3 # Start in POWDER_MAKING
        self.batch_number = 128
        self.target_batch_weight = 500.0 # kg
        self.current_batch_weight = 370.0 # kg
        self.state_start_time = time.time() - (27 * 60) # 27 mins elapsed
        self.target_cycle_minutes = 36.0
        self.current_rate_kg_h = 824.0

        # Production Totals
        self.today_kg = 15420.0
        self.daily_target_kg = 20000.0 # 20 TPD
        self.shift_kg = 4060.0
        self.shift_target_kg = 6667.0
        self.hourly_target_kg_h = 833.0
        self.current_shift = 2

        # Storage & Load Cells
        self.silo_1_kg = 1910.0
        self.silo_2_kg = 1910.0
        self.silo_capacity_kg = 5000.0
        self.syrup_tank_kg = 2940.0
        self.syrup_capacity_kg = 5000.0

        # Energy System
        self.live_power_kw = 103.0
        self.hourly_kwh = 103.0
        self.hourly_limit_kwh = 134.0
        self.shift_kwh = 742.0
        self.shift_limit_kwh = 1074.0
        self.daily_kwh = 2486.0
        self.daily_limit_kwh = 3221.0

        # Revolving Events Ticker
        self.events = [
            {"id": "EVT-1", "message": "Production target achieved (Shift 1)", "category": "POSITIVE", "priority": 30, "timestamp": datetime.now(timezone.utc).isoformat()},
            {"id": "EVT-2", "message": "Batch #127 completed successfully", "category": "POSITIVE", "priority": 30, "timestamp": datetime.now(timezone.utc).isoformat()},
            {"id": "EVT-3", "message": "Energy consumption within normal limit (103 kW)", "category": "POSITIVE", "priority": 30, "timestamp": datetime.now(timezone.utc).isoformat()},
            {"id": "EVT-4", "message": "Production rate at 812 kg/h (Target: 833 kg/h)", "category": "WARNING", "priority": 60, "timestamp": datetime.now(timezone.utc).isoformat()},
            {"id": "EVT-5", "message": "Combined Silo storage level at 76.4%", "category": "INFO", "priority": 10, "timestamp": datetime.now(timezone.utc).isoformat()},
        ]

        # Alarms Lifecycle
        self.alarms = [
            {
                "id": "ALM-001",
                "code": "PM_FAULT",
                "title": "Powder Maker Motor Over-Torque Warning",
                "equipment": "Powder Maker #1",
                "severity": "CRITICAL",
                "status": "ACTIVE",
                "triggered_at": datetime.now(timezone.utc).strftime("%H:%M"),
                "acknowledged_at": None,
                "acknowledged_by": None,
                "value": "Torque: 94%",
                "limit": "Max: 90%"
            },
            {
                "id": "ALM-002",
                "code": "RATE_LOW",
                "title": "Production Below Hourly Target",
                "equipment": "Main Line",
                "severity": "WARNING",
                "status": "ACTIVE",
                "triggered_at": datetime.now(timezone.utc).strftime("%H:%M"),
                "acknowledged_at": None,
                "acknowledged_by": None,
                "value": "812 kg/h",
                "limit": "Target: 833 kg/h"
            },
            {
                "id": "ALM-003",
                "code": "SILO_HIGH",
                "title": "Combined Silo Capacity High",
                "equipment": "Load Cells Silo 1+2",
                "severity": "WARNING",
                "status": "ACTIVE",
                "triggered_at": datetime.now(timezone.utc).strftime("%H:%M"),
                "acknowledged_at": None,
                "acknowledged_by": None,
                "value": "3,820 kg",
                "limit": "Max: 5,000 kg"
            },
        ]

        # Batch History
        self.batches = [
            {"batchId": "B-128", "batchNumber": 128, "weightKg": 370.0, "targetWeightKg": 500.0, "startTime": "13:30", "endTime": "--", "durationMinutes": 27.0, "status": "RUNNING"},
            {"batchId": "B-127", "batchNumber": 127, "weightKg": 502.4, "targetWeightKg": 500.0, "startTime": "12:50", "endTime": "13:26", "durationMinutes": 36.0, "status": "COMPLETED"},
            {"batchId": "B-126", "batchNumber": 126, "weightKg": 498.2, "targetWeightKg": 500.0, "startTime": "12:10", "endTime": "12:47", "durationMinutes": 37.0, "status": "COMPLETED"},
            {"batchId": "B-125", "batchNumber": 125, "weightKg": 501.0, "targetWeightKg": 500.0, "startTime": "11:32", "endTime": "12:07", "durationMinutes": 35.0, "status": "COMPLETED"},
        ]

    def tick(self):
        """Advances plant simulation with sensor fluctuations and state transitions."""
        # Minor fluctuations
        self.live_power_kw = round(103.0 + random.uniform(-2.5, 3.5), 1)
        self.silo_1_kg = round(self.silo_1_kg + random.uniform(-1.0, 1.5), 1)
        self.silo_2_kg = round(self.silo_2_kg + random.uniform(-1.0, 1.5), 1)
        self.syrup_tank_kg = round(2940.0 + random.uniform(-2.0, 2.0), 1)

        # In POWDER_MAKING state, increment batch weight gradually
        current_state_info = POWDER_MAKER_STATES[self.state_idx]
        if current_state_info["state"] == "POWDER_MAKING":
            self.current_batch_weight = min(self.target_batch_weight, round(self.current_batch_weight + 0.4, 1))

        # Check for state transition
        elapsed = time.time() - self.state_start_time
        if elapsed > current_state_info["duration"]:
            self.state_idx = (self.state_idx + 1) % len(POWDER_MAKER_STATES)
            self.state_start_time = time.time()
            new_state = POWDER_MAKER_STATES[self.state_idx]["state"]

            if new_state == "DISCHARGE":
                # Complete batch and increment
                self.today_kg += self.current_batch_weight
                self.shift_kg += self.current_batch_weight
                self.events.insert(0, {
                    "id": f"EVT-{int(time.time())}",
                    "message": f"✓ Batch #{self.batch_number} discharge completed ({self.current_batch_weight} kg)",
                    "category": "POSITIVE",
                    "priority": 30,
                    "timestamp": datetime.now(timezone.utc).isoformat()
                })
            elif new_state == "SYSTEM_READY":
                self.batch_number += 1
                self.current_batch_weight = 0.0
                self.events.insert(0, {
                    "id": f"EVT-{int(time.time())}",
                    "message": f"System ready for Batch #{self.batch_number}",
                    "category": "INFO",
                    "priority": 10,
                    "timestamp": datetime.now(timezone.utc).isoformat()
                })

        # Cap event queue to 10 latest
        if len(self.events) > 10:
            self.events = self.events[:10]

    def get_plant_health(self) -> Dict[str, Any]:
        """
        Calculates authoritative Plant Health based on the 5 operational weighted components:
        production: 30%, equipment: 30%, energy: 15%, storage: 15%, connectivity: 10%.
        """
        # Production: actual rate vs target (824 / 833) -> ~98% of 30 = 29.4
        prod_pct = min(1.0, self.current_rate_kg_h / self.hourly_target_kg_h)
        prod_score = prod_pct * 30.0

        # Equipment: check if critical faults exist
        has_critical = any(a["severity"] == "CRITICAL" and a["status"] == "ACTIVE" for a in self.alarms)
        equip_score = 25.0 if has_critical else 30.0

        # Energy: within limits (103 kW vs 134 limit) -> ~15
        energy_score = 15.0 if self.live_power_kw <= self.hourly_limit_kwh else 11.0

        # Storage: under 90% capacity
        combined_silo = self.silo_1_kg + self.silo_2_kg
        storage_score = 15.0 if (combined_silo / self.silo_capacity_kg) < 0.90 else 10.0

        # Connectivity: PLC is online
        conn_score = 10.0 if self.is_online else 0.0

        total_health = round(prod_score + equip_score + energy_score + storage_score + conn_score)

        return {
            "totalScore": total_health, # typically 94%
            "components": {
                "production": {"score": round(prod_score, 1), "max": 30, "status": "OPTIMAL"},
                "equipment": {"score": round(equip_score, 1), "max": 30, "status": "WARNING" if has_critical else "OPTIMAL"},
                "energy": {"score": round(energy_score, 1), "max": 15, "status": "OPTIMAL"},
                "storage": {"score": round(storage_score, 1), "max": 15, "status": "OPTIMAL"},
                "connectivity": {"score": round(conn_score, 1), "max": 10, "status": "CONNECTED"}
            }
        }

sim = PlantSimulationState()

# Background simulation runner
async def simulation_loop():
    while True:
        sim.tick()
        await asyncio.sleep(2.0)

@app.on_event("startup")
async def on_startup():
    asyncio.create_task(simulation_loop())

# ==============================================================================
# REST API ENDPOINTS (Documented in api-mapping.yaml)
# ==============================================================================

@app.get("/api/v1/health")
async def health_check():
    return {"status": "ok", "plant": sim.name, "timestamp": datetime.now(timezone.utc).isoformat()}

@app.get("/api/v1/telemetry/live")
async def get_live_telemetry():
    pm_info = POWDER_MAKER_STATES[sim.state_idx]
    elapsed_sec = int(time.time() - sim.state_start_time)
    sec_kwh_per_kg = round(sim.hourly_kwh / max(1.0, sim.current_rate_kg_h), 3)

    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "plant": {
            "name": sim.name,
            "products": sim.business_units,
            "active_product": "Jaggery Powder"
        },
        "production": {
            "shift_number": sim.current_shift,
            "shift_duration_hours": 8,
            "shift_elapsed_seconds": 15420,
            "hourly_target_kg": sim.hourly_target_kg_h,
            "hourly_actual_kg": round(sim.current_rate_kg_h, 1),
            "shift_target_kg": sim.shift_target_kg,
            "shift_actual_kg": round(sim.shift_kg, 1),
            "plant_capacity_tpd": 20.0,
            "daily_actual_kg": round(sim.today_kg, 1)
        },
        "powder_maker": {
            "status": pm_info["display"],
            "batch_capacity_kg": sim.target_batch_weight,
            "batch_current_kg": round(sim.current_batch_weight, 1),
            "batch_cycle_seconds": elapsed_sec % 300,
            "completed_batches_today": max(1, sim.batch_number - 110)
        },
        "storage": {
            "silo_1_kg": round(sim.silo_1_kg, 1),
            "silo_2_kg": round(sim.silo_2_kg, 1),
            "combined_silos_kg": round(sim.silo_1_kg + sim.silo_2_kg, 1),
            "combined_max_capacity_kg": sim.silo_capacity_kg,
            "syrup_tank_kg": round(sim.syrup_tank_kg, 1),
            "syrup_tank_max_kg": sim.syrup_capacity_kg,
            "load_cells_healthy": True
        },
        "electricity": {
            "current_power_kw": round(sim.live_power_kw, 1),
            "hourly_kwh": round(sim.hourly_kwh, 1),
            "hourly_max_kwh": sim.hourly_limit_kwh,
            "shift_kwh": round(sim.shift_kwh, 1),
            "shift_max_kwh": sim.shift_limit_kwh,
            "daily_kwh": round(sim.daily_kwh, 1),
            "daily_max_kwh": sim.daily_limit_kwh,
            "sec_kwh_per_kg": sec_kwh_per_kg
        }
    }

@app.get("/api/v1/plant/status")
async def get_plant_status():
    health = sim.get_plant_health()
    return {
        "plantId": sim.plant_id,
        "name": sim.name,
        "location": sim.location,
        "businessUnits": sim.business_units,
        "connectionStatus": "LIVE" if sim.is_online else "OFFLINE",
        "healthScore": health["totalScore"],
        "healthBreakdown": health["components"],
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

@app.get("/api/v1/telemetry/events")
async def get_telemetry_events():
    return sim.events

@app.get("/api/v1/production/summary")
@app.get("/api/v1/production/kpis")
async def get_production_summary():
    daily_pct = round((sim.today_kg / sim.daily_target_kg) * 100, 1)
    rate_target_pct = round((sim.current_rate_kg_h / sim.hourly_target_kg_h) * 100, 1)
    return {
        "todayKg": round(sim.today_kg, 1),
        "dailyTargetKg": sim.daily_target_kg,
        "dailyTargetPercent": daily_pct,
        "hourlyRateKgH": round(sim.current_rate_kg_h, 1),
        "hourlyTargetKgH": sim.hourly_target_kg_h,
        "hourlyTargetPercent": rate_target_pct,
        "shiftKg": round(sim.shift_kg, 1),
        "shiftTargetKg": sim.shift_target_kg,
        "energyKwh": round(sim.daily_kwh, 1),
        "energyBudgetKwh": sim.daily_limit_kwh,
        "currentShift": sim.current_shift
    }

@app.get("/api/v1/production/batches")
async def get_production_batches():
    return sim.batches

@app.get("/api/v1/process/powder-maker")
async def get_powder_maker_state():
    info = POWDER_MAKER_STATES[sim.state_idx]
    progress = round((sim.current_batch_weight / sim.target_batch_weight) * 100, 1) if sim.target_batch_weight > 0 else 0.0
    elapsed_mins = round((time.time() - sim.state_start_time) / 60.0, 1)
    return {
        "currentState": info["state"],
        "stateDisplayName": info["display"],
        "batchNumber": sim.batch_number,
        "currentWeightKg": round(sim.current_batch_weight, 1),
        "targetWeightKg": sim.target_batch_weight,
        "progressPercent": progress,
        "elapsedMinutes": elapsed_mins,
        "targetCycleMinutes": sim.target_cycle_minutes,
        "currentRateKgH": sim.current_rate_kg_h,
        "equipmentStatus": "RUNNING"
    }

@app.get("/api/v1/storage/levels")
async def get_storage_levels():
    combined_weight = round(sim.silo_1_kg + sim.silo_2_kg, 1)
    combined_pct = round((combined_weight / sim.silo_capacity_kg) * 100, 1)
    syrup_pct = round((sim.syrup_tank_kg / sim.syrup_capacity_kg) * 100, 1)
    return {
        "combinedSilo": {
            "name": "Combined Silo",
            "silo1Kg": sim.silo_1_kg,
            "silo2Kg": sim.silo_2_kg,
            "combinedWeightKg": combined_weight,
            "capacityKg": sim.silo_capacity_kg,
            "fillPercent": combined_pct,
            "warning": combined_pct > 85.0
        },
        "syrupTank": {
            "name": "Syrup Tank",
            "weightKg": sim.syrup_tank_kg,
            "capacityKg": sim.syrup_capacity_kg,
            "fillPercent": syrup_pct,
            "warning": syrup_pct > 85.0
        },
        "validationStatus": "ALL SENSORS VALIDATED"
    }

@app.get("/api/v1/energy/overview")
async def get_energy_overview():
    efficiency = round(sim.hourly_kwh / max(1.0, sim.current_rate_kg_h), 3) # kWh/kg
    return {
        "livePowerKw": sim.live_power_kw,
        "hourlyKwh": sim.hourly_kwh,
        "hourlyLimitKwh": sim.hourly_limit_kwh,
        "shiftKwh": sim.shift_kwh,
        "shiftLimitKwh": sim.shift_limit_kwh,
        "dailyKwh": sim.daily_kwh,
        "dailyLimitKwh": sim.daily_limit_kwh,
        "efficiencyKwhPerKg": efficiency,
        "hourlyTrend": [
            {"hour": "10:00", "kw": 98.0},
            {"hour": "11:00", "kw": 102.5},
            {"hour": "12:00", "kw": 105.0},
            {"hour": "13:00", "kw": 101.8},
            {"hour": "14:00", "kw": sim.live_power_kw},
        ]
    }

@app.get("/api/v1/alarms")
async def get_alarms():
    critical = sum(1 for a in sim.alarms if a["severity"] == "CRITICAL" and a["status"] == "ACTIVE")
    warnings = sum(1 for a in sim.alarms if a["severity"] == "WARNING" and a["status"] == "ACTIVE")
    return {
        "criticalCount": critical,
        "warningCount": warnings,
        "alarms": sim.alarms
    }

@app.post("/api/v1/alarms/{alarm_id}/acknowledge")
async def acknowledge_alarm(alarm_id: str):
    for alarm in sim.alarms:
        if alarm["id"] == alarm_id:
            alarm["status"] = "ACKNOWLEDGED"
            alarm["acknowledged_at"] = datetime.now(timezone.utc).strftime("%H:%M:%S")
            alarm["acknowledged_by"] = "Operator (John Doe)"
            return {
                "success": True,
                "alarmId": alarm_id,
                "status": "ACKNOWLEDGED",
                "acknowledgedAt": alarm["acknowledged_at"]
            }
    raise HTTPException(status_code=404, detail="Alarm ID not found")

if __name__ == "__main__":
    print("=" * 70)
    print("  Auraliss - Corelife Wholefoods Industrial Simulation Server")
    print("  Plant: Corelife Wholefoods (Jaggery & Liquid Sugars)")
    print("  Listening on http://0.0.0.0:8000 (Local PC and LAN / Internet tunnel)")
    print("=" * 70)
    uvicorn.run(app, host="0.0.0.0", port=8000)
