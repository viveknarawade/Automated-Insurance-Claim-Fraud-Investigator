import { useEffect, useState } from "react";
import DashboardLayout from "../components/DashboardLayout";
import { getAdminDashboard } from "../services/adminService";
import {
  BarChart3, Loader2, AlertTriangle, FileText, Clock,
  CheckCircle2, XCircle, ShieldAlert, Activity, TrendingUp,
} from "lucide-react";

function AnalyticsBar({ label, value, total, color }) {
  const pct = total > 0 ? Math.round((value / total) * 100) : 0;
  return (
    <div className="space-y-1.5">
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-slate-700">{label}</span>
        <span className="text-sm font-bold text-slate-900">{value} <span className="text-xs text-slate-400 font-normal">({pct}%)</span></span>
      </div>
      <div className="h-3 w-full rounded-full bg-slate-100 overflow-hidden">
        <div className={`h-full rounded-full ${color} transition-all duration-700`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function MetricCard({ icon: Icon, iconBg, label, value, loading }) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 flex items-center gap-4 shadow-sm">
      <div className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-xl ${iconBg}`}>
        <Icon className="h-5 w-5" />
      </div>
      <div>
        <p className="text-xs font-medium text-slate-500 uppercase tracking-wide">{label}</p>
        {loading ? <div className="mt-1 h-7 w-12 rounded bg-slate-100 animate-pulse" /> : (
          <p className="text-2xl font-bold text-slate-900">{value}</p>
        )}
      </div>
    </div>
  );
}

export default function AdminAnalyticsPage() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => { fetchData(); }, []);

  const fetchData = async () => {
    try { setLoading(true); setError("");
      const res = await getAdminDashboard();
      setData(res.data?.data);
    } catch { setError("Failed to load analytics."); }
    finally { setLoading(false); }
  };

  const d = data || {};
  const total = d.totalClaims || 1;

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
            <BarChart3 className="h-6 w-6 text-slate-900" /> Analytics
          </h1>
          <p className="text-sm text-slate-500 mt-0.5">Visual breakdown of claims across all statuses.</p>
        </div>

        {error && (
          <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            <AlertTriangle className="h-4 w-4 shrink-0" /> {error}
            <button onClick={fetchData} className="ml-auto text-xs text-slate-900 hover:underline">Retry</button>
          </div>
        )}

        {/* Summary cards */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <MetricCard icon={FileText} iconBg="bg-slate-100 text-slate-600" label="Total Claims" value={d.totalClaims ?? 0} loading={loading} />
          <MetricCard icon={TrendingUp} iconBg="bg-slate-100 text-slate-900" label="Active" value={d.activeClaims ?? 0} loading={loading} />
          <MetricCard icon={ShieldAlert} iconBg="bg-slate-100 text-slate-900" label="Suspected Fraud" value={d.suspectedFraudClaims ?? 0} loading={loading} />
          <MetricCard icon={AlertTriangle} iconBg="bg-red-100 text-red-700" label="Confirmed Fraud" value={d.confirmedFraudClaims ?? 0} loading={loading} />
        </div>

        {/* Charts */}
        <div className="grid lg:grid-cols-2 gap-6">
          {/* Claim Status Breakdown */}
          <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
            <h2 className="text-sm font-semibold text-slate-800 mb-5 flex items-center gap-2">
              <Activity className="h-4 w-4 text-slate-700" /> Claim Status Breakdown
            </h2>
            {loading ? (
              <div className="flex items-center justify-center py-12 text-slate-400"><Loader2 className="h-5 w-5 animate-spin" /></div>
            ) : (
              <div className="space-y-4">
                <AnalyticsBar label="Pending" value={d.pendingClaims ?? 0} total={total} color="bg-slate-700" />
                <AnalyticsBar label="Under Review" value={d.underReviewClaims ?? 0} total={total} color="bg-slate-700" />
                <AnalyticsBar label="Approved" value={d.approvedClaims ?? 0} total={total} color="bg-slate-700" />
                <AnalyticsBar label="Rejected" value={d.rejectedClaims ?? 0} total={total} color="bg-red-500" />
                <AnalyticsBar label="Active" value={d.activeClaims ?? 0} total={total} color="bg-slate-700" />
              </div>
            )}
          </div>

          {/* Fraud Analysis */}
          <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
            <h2 className="text-sm font-semibold text-slate-800 mb-5 flex items-center gap-2">
              <ShieldAlert className="h-4 w-4 text-slate-700" /> Fraud Analysis
            </h2>
            {loading ? (
              <div className="flex items-center justify-center py-12 text-slate-400"><Loader2 className="h-5 w-5 animate-spin" /></div>
            ) : (
              <div className="space-y-4">
                <AnalyticsBar label="Suspected Fraud" value={d.suspectedFraudClaims ?? 0} total={total} color="bg-slate-700" />
                <AnalyticsBar label="Confirmed Fraud" value={d.confirmedFraudClaims ?? 0} total={total} color="bg-red-600" />

                {/* Fraud rate card */}
                <div className="mt-6 rounded-lg bg-gradient-to-r from-slate-50 to-red-50 border border-slate-200 p-4">
                  <p className="text-xs font-semibold text-slate-900 uppercase tracking-wide mb-1">Fraud Rate</p>
                  <p className="text-3xl font-bold text-slate-900">
                    {total > 0 ? (((d.suspectedFraudClaims ?? 0) + (d.confirmedFraudClaims ?? 0)) / total * 100).toFixed(1) : 0}%
                  </p>
                  <p className="text-xs text-slate-900 mt-1">
                    {(d.suspectedFraudClaims ?? 0) + (d.confirmedFraudClaims ?? 0)} of {d.totalClaims ?? 0} total claims flagged
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
