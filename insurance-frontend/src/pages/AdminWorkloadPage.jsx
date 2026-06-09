import { useEffect, useState } from "react";
import DashboardLayout from "../components/DashboardLayout";
import { getInvestigatorsWorkload } from "../services/adminService";
import { Activity, Loader2, AlertTriangle, Users } from "lucide-react";

const MAX_CAPACITY = 25;

function getUtilColor(pct) {
  if (pct < 40) return { bar: "bg-slate-700", badge: "bg-slate-100 text-slate-900" };
  if (pct < 70) return { bar: "bg-slate-700", badge: "bg-slate-100 text-slate-900" };
  return { bar: "bg-red-500", badge: "bg-red-700 text-white" };
}

function InvestigatorCard({ inv }) {
  const active = inv.activeClaims ?? 0;
  const pct = Math.min(Math.round((active / MAX_CAPACITY) * 100), 100);
  const colors = getUtilColor(pct);
  const initials = inv.fullName?.split(" ").map(n => n[0]).join("").toUpperCase().slice(0, 2) || "??";

  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5 hover:shadow-md transition-shadow">
      {/* Header */}
      <div className="flex items-center gap-3 mb-4">
        <div className="flex h-11 w-11 items-center justify-center rounded-full bg-gradient-to-br from-slate-500 to-slate-600 text-white text-sm font-bold shrink-0">
          {initials}
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-semibold text-slate-800 truncate">{inv.fullName}</p>
          <p className="text-xs text-slate-400 truncate">ID: {inv.investigatorId}</p>
        </div>
        <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-bold ${colors.badge}`}>
          {pct}%
        </span>
      </div>

      {/* Capacity bar */}
      <div className="mb-1.5 flex items-center justify-between">
        <p className="text-xs font-medium text-slate-500">Capacity utilization</p>
        <p className="text-xs text-slate-500 font-medium">{active} / {MAX_CAPACITY} open</p>
      </div>
      <div className="h-2 w-full rounded-full bg-slate-100 overflow-hidden">
        <div className={`h-full rounded-full ${colors.bar} transition-all duration-500`} style={{ width: `${pct}%` }} />
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-3 gap-3 mt-5 pt-4 border-t border-slate-100">
        {[
          { label: "ACTIVE", value: active, color: "text-slate-900" },
          { label: "AVAILABLE", value: MAX_CAPACITY - active, color: "text-slate-900" },
          { label: "CAPACITY", value: MAX_CAPACITY, color: "text-slate-600" },
        ].map(s => (
          <div key={s.label} className="text-center">
            <p className="text-[10px] font-semibold uppercase tracking-wider text-slate-400">{s.label}</p>
            <p className={`text-lg font-bold ${s.color}`}>{s.value}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function AdminWorkloadPage() {
  const [workload, setWorkload] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => { fetchWorkload(); }, []);

  const fetchWorkload = async () => {
    try { setLoading(true); setError("");
      const res = await getInvestigatorsWorkload();
      setWorkload(res.data?.data || []);
    } catch { setError("Failed to load investigator workload."); }
    finally { setLoading(false); }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
            <Activity className="h-6 w-6 text-slate-900" /> Investigator Workload
          </h1>
          <p className="text-sm text-slate-500 mt-0.5">Capacity, current open cases, and recent throughput per investigator.</p>
        </div>

        {error && (
          <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            <AlertTriangle className="h-4 w-4 shrink-0" /> {error}
            <button onClick={fetchWorkload} className="ml-auto text-xs text-slate-900 hover:underline">Retry</button>
          </div>
        )}

        {loading ? (
          <div className="flex items-center justify-center py-20 gap-2 text-slate-400">
            <Loader2 className="h-6 w-6 animate-spin" /> <span>Loading workload data…</span>
          </div>
        ) : workload.length === 0 ? (
          <div className="flex flex-col items-center py-20 text-slate-400">
            <Users className="h-12 w-12 mb-3 text-slate-300" />
            <p className="text-sm font-medium text-slate-600">No investigators found</p>
            <p className="text-xs mt-1">Investigators will appear here once assigned.</p>
          </div>
        ) : (
          <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-5">
            {workload.map(inv => (
              <InvestigatorCard key={inv.investigatorId} inv={inv} />
            ))}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
