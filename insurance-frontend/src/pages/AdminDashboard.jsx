import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import DashboardLayout from "../components/DashboardLayout";
import {
  getAdminDashboard,
  assignInvestigator,
  approveClaim,
  rejectClaim,
} from "../services/adminService";
import { getAllUnsignedClaims } from "../services/claimService";
import {
  LayoutDashboard, FileText, Clock, CheckCircle2, XCircle,
  ShieldAlert, AlertTriangle, Loader2, Users, Activity,
  ArrowRight, UserCheck, ThumbsUp, ThumbsDown, X, Send,
  BarChart3, Eye,
} from "lucide-react";

// ── Helpers ──────────────────────────────d──────────────────────────────────
function pretty(str) {
  return str?.replace(/_/g, " ").toLowerCase().replace(/\b\w/g, c => c.toUpperCase()) || "—";
}
function fmtDate(raw) {
  if (!raw) return "—";
  return new Date(raw).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" });
}
function fmtAmount(n) {
  return `₹${Number(n).toLocaleString("en-IN")}`;
}

// ── Status badge ──────────────────────────────────────────────────────────
function StatusBadge({ status }) {
  const map = {
    APPROVED:     { cls: "bg-slate-50 text-slate-900 ring-slate-200" },
    UNDER_REVIEW: { cls: "bg-slate-50 text-slate-900 ring-slate-200" },
    PENDING:      { cls: "bg-slate-50 text-slate-900 ring-slate-200" },
    REJECTED:     { cls: "bg-red-50 text-red-700 ring-red-200" },
    FLAGGED:      { cls: "bg-slate-50 text-slate-900 ring-slate-200" },
  };
  const cfg = map[status] || { cls: "bg-slate-50 text-slate-600 ring-slate-200" };
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ${cfg.cls}`}>
      {pretty(status)}
    </span>
  );
}

function FraudBadge({ status }) {
  const map = {
    SUSPICIOUS:      { cls: "bg-slate-50 text-slate-900 ring-slate-200" },
    CONFIRMED_FRAUD: { cls: "bg-red-50 text-red-700 ring-red-200" },
    CLEARED:         { cls: "bg-slate-50 text-slate-900 ring-slate-200" },
  };
  const cfg = map[status] || { cls: "bg-slate-50 text-slate-500 ring-slate-200" };
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ${cfg.cls}`}>
      {status ? pretty(status) : "Unreviewed"}
    </span>
  );
}

// ── Stat card ─────────────────────────────────────────────────────────────
function StatCard({ icon: Icon, iconBg, label, value, loading }) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 flex items-center gap-4 shadow-sm hover:shadow-md transition-shadow">
      <div className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-xl ${iconBg}`}>
        <Icon className="h-5 w-5" />
      </div>
      <div>
        <p className="text-xs font-medium text-slate-500 uppercase tracking-wide">{label}</p>
        {loading ? (
          <div className="mt-1 h-6 w-10 rounded bg-slate-100 animate-pulse" />
        ) : (
          <p className="text-2xl font-bold text-slate-900">{value}</p>
        )}
      </div>
    </div>
  );
}

// ── Action modal ──────────────────────────────────────────────────────────
function ActionModal({ title, children, onClose }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" onClick={onClose}>
      <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full mx-4 p-6" onClick={e => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-slate-900">{title}</h3>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-600 transition-colors">
            <X className="h-5 w-5" />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

// ── Main ──────────────────────────────────────────────────────────────────
export default function AdminDashboard() {
  const navigate = useNavigate();

  const [dashboard, setDashboard] = useState(null);
  const [claims, setClaims]       = useState([]);
  const [loading, setLoading]     = useState(true);
  const [error, setError]         = useState("");

  // modal state
  const [modal, setModal] = useState(null); // { type: 'assign'|'approve'|'reject', claim }
  const [modalLoading, setModalLoading] = useState(false);
  const [modalError, setModalError] = useState("");
  const [notes, setNotes] = useState("");
  const [selectedInvestigator, setSelectedInvestigator] = useState("");

  useEffect(() => { fetchAll(); }, []);

  const fetchAll = async () => {
    try {
      setLoading(true);
      setError("");
      const [dashRes, claimsRes] = await Promise.all([
        getAdminDashboard(),
        getAllUnsignedClaims(),
      ]);
      setDashboard(dashRes.data?.data);
      setClaims(claimsRes.data.data || []);
    } catch (err) {
      setError("Failed to load dashboard data.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleAssign = async () => {
    if (!selectedInvestigator) { setModalError("Select an investigator."); return; }
    setModalLoading(true); setModalError("");
    try {
      await assignInvestigator(modal.claim.claimId, Number(selectedInvestigator));
      setModal(null); setSelectedInvestigator("");
      fetchAll();
    } catch (err) {
      setModalError(err.response?.data?.message || "Assignment failed.");
    } finally { setModalLoading(false); }
  };

  const handleDecision = async (type) => {
    if (!notes.trim()) { setModalError("Decision notes are required."); return; }
    setModalLoading(true); setModalError("");
    try {
      const fn = type === "approve" ? approveClaim : rejectClaim;
      await fn(modal.claim.claimId, notes.trim());
      setModal(null); setNotes("");
      fetchAll();
    } catch (err) {
      setModalError(err.response?.data?.message || "Action failed.");
    } finally { setModalLoading(false); }
  };

  const d = dashboard || {};

  return (
    <DashboardLayout>
      <div className="space-y-6">

        {/* Header */}
        <div>
          <h1 className="text-2xl font-bold text-slate-900 flex items-center gap-2">
            <LayoutDashboard className="h-6 w-6 text-slate-900" /> Admin Dashboard
          </h1>
          <p className="text-sm text-slate-500 mt-0.5">Overview of all insurance claims and operations.</p>
        </div>

        {error && (
          <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            <AlertTriangle className="h-4 w-4 shrink-0" /> {error}
            <button onClick={fetchAll} className="ml-auto text-xs text-slate-900 hover:underline">Retry</button>
          </div>
        )}

        {/* Stat cards */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard icon={FileText}     iconBg="bg-slate-100 text-slate-600"     label="Total Claims"    value={d.totalClaims ?? 0}          loading={loading} />
          <StatCard icon={Clock}        iconBg="bg-slate-100 text-slate-900"       label="Pending"         value={d.pendingClaims ?? 0}        loading={loading} />
          <StatCard icon={Activity}     iconBg="bg-slate-100 text-slate-900"     label="Under Review"    value={d.underReviewClaims ?? 0}    loading={loading} />
          <StatCard icon={CheckCircle2} iconBg="bg-slate-100 text-slate-900" label="Approved"        value={d.approvedClaims ?? 0}       loading={loading} />
          <StatCard icon={XCircle}      iconBg="bg-red-100 text-red-600"         label="Rejected"        value={d.rejectedClaims ?? 0}       loading={loading} />
          <StatCard icon={ShieldAlert}  iconBg="bg-slate-100 text-slate-900"   label="Suspected Fraud" value={d.suspectedFraudClaims ?? 0} loading={loading} />
          <StatCard icon={AlertTriangle} iconBg="bg-red-100 text-red-700"        label="Confirmed Fraud" value={d.confirmedFraudClaims ?? 0} loading={loading} />
          <StatCard icon={BarChart3}    iconBg="bg-slate-100 text-slate-900"   label="Active Claims"   value={d.activeClaims ?? 0}         loading={loading} />
        </div>



        {/*Claims */}
        <div className="lg:col-span-2 bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
            <div className="flex items-center justify-between px-5 py-4 border-b border-slate-100">
              <div>
                <h2 className="text-sm font-semibold text-slate-800">All Claims</h2>
                <p className="text-xs text-slate-400 mt-0.5">Recent claims across all users</p>
              </div>
            </div>

            {loading ? (
              <div className="flex items-center justify-center py-12 gap-2 text-slate-400">
                <Loader2 className="h-5 w-5 animate-spin" /> <span className="text-sm">Loading…</span>
              </div>
            ) : claims.length === 0 ? (
              <div className="flex flex-col items-center py-14 text-slate-400">
                <FileText className="h-10 w-10 mb-3 text-slate-300" />
                <p className="text-sm font-medium text-slate-600">No claims found</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-slate-100 bg-slate-50/60">
                      {["Claim #", "Type", "Amount", "Status", "Fraud", "Actions"].map(h => (
                        <th key={h} className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide text-slate-500">{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {claims.map(claim => (
                      <tr key={claim.claimId} className="hover:bg-slate-50 transition-colors">
                        <td className="px-4 py-3 font-medium text-slate-900">
                          <button onClick={() => navigate(`/admin/claims/${claim.claimId}`)} className="hover:underline">
                            {claim.claimNumber}
                          </button>
                        </td>
                        <td className="px-4 py-3 text-slate-600 capitalize">{claim.claimType?.toLowerCase()}</td>
                        <td className="px-4 py-3 text-slate-700 font-medium">{fmtAmount(claim.claimAmount)}</td>
                        <td className="px-4 py-3"><StatusBadge status={claim.claimStatus} /></td>
                        <td className="px-4 py-3"><FraudBadge status={claim.fraudStatus} /></td>
                        <td className="px-4 py-3">
                          <div className="flex items-center gap-1">
                            <button onClick={() => { setModal({ type: "assign", claim }); setModalError(""); }}
                              title="Assign Investigator"
                              className="p-1.5 rounded-md text-slate-400 hover:text-slate-900 hover:bg-slate-50 transition-colors">
                              <UserCheck className="h-4 w-4" />
                            </button>
                            <button onClick={() => { setModal({ type: "approve", claim }); setNotes(""); setModalError(""); }}
                              title="Approve"
                              className="p-1.5 rounded-md text-slate-400 hover:text-slate-900 hover:bg-slate-50 transition-colors">
                              <ThumbsUp className="h-4 w-4" />
                            </button>
                            <button onClick={() => { setModal({ type: "reject", claim }); setNotes(""); setModalError(""); }}
                              title="Reject"
                              className="p-1.5 rounded-md text-slate-400 hover:text-red-600 hover:bg-red-50 transition-colors">
                              <ThumbsDown className="h-4 w-4" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
      </div>

      {/* ── Modals ── */}
      {modal?.type === "assign" && (
        <ActionModal title={`Assign Investigator — ${modal.claim.claimNumber}`} onClose={() => setModal(null)}>
          <div className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-600 uppercase tracking-wide mb-1.5">Investigator *</label>
              <select value={selectedInvestigator} onChange={e => { setSelectedInvestigator(e.target.value); setModalError(""); }}
                className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-500/30 focus:border-slate-500">
                <option value="">Select investigator…</option>
                {workload.map(inv => (
                  <option key={inv.investigatorId} value={inv.investigatorId}>
                    {inv.fullName} ({inv.activeClaims} active)
                  </option>
                ))}
              </select>
            </div>
            {modalError && <p className="text-xs text-red-500 flex items-center gap-1"><AlertTriangle className="h-3 w-3" /> {modalError}</p>}
            <button onClick={handleAssign} disabled={modalLoading}
              className="w-full flex items-center justify-center gap-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-white text-sm font-medium py-2.5 transition-colors disabled:opacity-60">
              {modalLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
              {modalLoading ? "Assigning…" : "Assign Investigator"}
            </button>
          </div>
        </ActionModal>
      )}

      {(modal?.type === "approve" || modal?.type === "reject") && (
        <ActionModal
          title={`${modal.type === "approve" ? "Approve" : "Reject"} Claim — ${modal.claim.claimNumber}`}
          onClose={() => setModal(null)}
        >
          <div className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-slate-600 uppercase tracking-wide mb-1.5">Decision Notes *</label>
              <textarea rows={3} value={notes} onChange={e => { setNotes(e.target.value); setModalError(""); }}
                placeholder="Provide reason for this decision…"
                className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-500/30 focus:border-slate-500 resize-none" />
            </div>
            {modalError && <p className="text-xs text-red-500 flex items-center gap-1"><AlertTriangle className="h-3 w-3" /> {modalError}</p>}
            <button onClick={() => handleDecision(modal.type)} disabled={modalLoading}
              className={`w-full flex items-center justify-center gap-2 rounded-lg text-white text-sm font-medium py-2.5 transition-colors disabled:opacity-60 ${
                modal.type === "approve"
                  ? "bg-slate-900 hover:bg-slate-800"
                  : "bg-red-600 hover:bg-red-700"
              }`}>
              {modalLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : modal.type === "approve" ? <ThumbsUp className="h-4 w-4" /> : <ThumbsDown className="h-4 w-4" />}
              {modalLoading ? "Processing…" : modal.type === "approve" ? "Approve Claim" : "Reject Claim"}
            </button>
          </div>
        </ActionModal>
      )}
    </DashboardLayout>
  );
}
