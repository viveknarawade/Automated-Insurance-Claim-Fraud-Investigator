import { useNavigate } from "react-router-dom";
import DashboardLayout from "../../components/DashboardLayout";
import { getUser, getRefreshToken, clearAuthData } from "../../utils/auth";
import { logout } from "../../services/authService";
import { User, Mail, Shield, Building, CheckCircle, Calendar, Edit2, Lock, LogOut, Trash2, X } from "lucide-react";
import { useState } from "react";

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

export default function ProfilePage() {
  const navigate = useNavigate();
  const user = getUser();
  const [loggingOut, setLoggingOut] = useState(false);
  const [modal, setModal] = useState(null); // null, 'edit', 'password'

  // Form states
  const [fullName, setFullName] = useState(user?.fullName || "");
  const [email, setEmail] = useState(user?.email || "");

  // Password states
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  // Derive display values
  const initials = user?.fullName?.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2) || "??";
  
  const handleSignOut = async () => {
    if (!window.confirm("Are you sure you want to sign out?")) return;
    try {
      setLoggingOut(true);
      await logout({ refreshToken: getRefreshToken() });
    } catch (err) {
      console.error(err);
    } finally {
      clearAuthData();
      navigate("/");
    }
  };

  const handleSaveProfile = (e) => {
    e.preventDefault();
    // Implementation would call API
    setModal(null);
  };

  const handleUpdatePassword = (e) => {
    e.preventDefault();
    // Implementation would call API
    setModal(null);
    setCurrentPassword("");
    setNewPassword("");
    setConfirmPassword("");
  };

  const InfoRow = ({ icon: Icon, label, value }) => (
    <div className="flex items-center gap-3">
      <div className="flex items-center justify-center w-6 h-6 shrink-0">
        <Icon className="w-4 h-4 text-slate-400" />
      </div>
      <div className="flex flex-1 items-center">
        <span className="w-32 sm:w-48 text-sm text-slate-500">{label}</span>
        <span className="text-sm font-medium text-slate-900">{value}</span>
      </div>
    </div>
  );

  return (
    <DashboardLayout>
      <div className="max-w-3xl">
        <div className="mb-6 mt-4">
          <h1 className="text-2xl font-bold text-slate-900">My Profile</h1>
          <p className="text-sm text-slate-500 mt-1">Manage your account settings</p>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6 mb-6">
          <div className="flex items-center gap-5 mb-8">
            <div className="flex items-center justify-center w-20 h-20 rounded-full bg-slate-100 text-2xl font-semibold text-slate-900 shrink-0">
              {initials}
            </div>
            <div>
              <h2 className="text-xl font-bold text-slate-900">{user?.fullName || "User"}</h2>
              <p className="text-sm text-slate-500 mt-0.5">{user?.email || "—"}</p>
              <div className="flex items-center gap-2 mt-3">
                <span className="inline-flex items-center px-2.5 py-0.5 rounded text-xs font-semibold uppercase tracking-wide bg-slate-100 text-slate-700">
                  {user?.role || "CUSTOMER"}
                </span>
                <span className="inline-flex items-center px-2.5 py-0.5 rounded text-xs font-semibold uppercase tracking-wide bg-emerald-50 text-emerald-700">
                  Active
                </span>
              </div>
            </div>
          </div>

          <div className="h-px bg-slate-100 w-full mb-6" />

          <div className="space-y-5">
            <InfoRow icon={User} label="Full Name" value={user?.fullName || "—"} />
            <InfoRow icon={Mail} label="Email" value={user?.email || "—"} />
            <InfoRow icon={Shield} label="Role" value={user?.role || "CUSTOMER"} />
            <InfoRow icon={Building} label="Tenant Code" value={user?.tenantCode || "—"} />
            <InfoRow icon={CheckCircle} label="Account Status" value="ACTIVE" />
            <InfoRow icon={Calendar} label="Member Since" value={user?.createdAt ? new Date(user.createdAt).toLocaleDateString() : "6/9/2026"} />
          </div>
        </div>

        <div className="grid sm:grid-cols-2 gap-4">
          <button onClick={() => setModal('edit')} className="flex items-center gap-3 px-4 py-3 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors text-sm font-semibold text-slate-700">
            <Edit2 className="w-4 h-4 text-slate-400" />
            Edit Profile
          </button>
          <button onClick={() => setModal('password')} className="flex items-center gap-3 px-4 py-3 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors text-sm font-semibold text-slate-700">
            <Lock className="w-4 h-4 text-slate-400" />
            Change Password
          </button>
          <button onClick={handleSignOut} disabled={loggingOut} className="flex items-center gap-3 px-4 py-3 bg-white border border-amber-200 rounded-xl hover:bg-amber-50 transition-colors text-sm font-semibold text-amber-600">
            <LogOut className="w-4 h-4" />
            {loggingOut ? "Signing out..." : "Sign Out"}
          </button>
          <button className="flex items-center gap-3 px-4 py-3 bg-white border border-red-200 rounded-xl hover:bg-red-50 transition-colors text-sm font-semibold text-red-600">
            <Trash2 className="w-4 h-4" />
            Delete Account
          </button>
        </div>

        {/* Modals */}
        {modal === 'edit' && (
          <ActionModal title="Edit Profile" onClose={() => setModal(null)}>
            <form onSubmit={handleSaveProfile} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1.5">Full Name</label>
                <input type="text" value={fullName} onChange={e => setFullName(e.target.value)}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-slate-500/30 focus:border-slate-500" />
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1.5">Email</label>
                <input type="email" value={email} onChange={e => setEmail(e.target.value)}
                  className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-500 cursor-not-allowed focus:outline-none" disabled />
              </div>
              <div className="flex justify-end gap-3 pt-2">
                <button type="button" onClick={() => setModal(null)} className="px-4 py-2 text-sm font-medium text-slate-600 hover:text-slate-800 transition-colors">Cancel</button>
                <button type="submit" className="px-4 py-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-white text-sm font-medium transition-colors">Save Changes</button>
              </div>
            </form>
          </ActionModal>
        )}

        {modal === 'password' && (
          <ActionModal title="Change Password" onClose={() => setModal(null)}>
            <form onSubmit={handleUpdatePassword} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1.5">Current Password</label>
                <input type="password" value={currentPassword} onChange={e => setCurrentPassword(e.target.value)}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-slate-500/30 focus:border-slate-500" />
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1.5">New Password</label>
                <input type="password" value={newPassword} onChange={e => setNewPassword(e.target.value)}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-slate-500/30 focus:border-slate-500" />
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1.5">Confirm New Password</label>
                <input type="password" value={confirmPassword} onChange={e => setConfirmPassword(e.target.value)}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-slate-500/30 focus:border-slate-500" />
              </div>
              <div className="flex justify-end gap-3 pt-2">
                <button type="button" onClick={() => setModal(null)} className="px-4 py-2 text-sm font-medium text-slate-600 hover:text-slate-800 transition-colors">Cancel</button>
                <button type="submit" className="px-4 py-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-white text-sm font-medium transition-colors">Update Password</button>
              </div>
            </form>
          </ActionModal>
        )}

      </div>
    </DashboardLayout>
  );
}
