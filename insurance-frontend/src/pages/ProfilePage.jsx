import { useNavigate } from "react-router-dom";
import DashboardLayout from "../components/DashboardLayout";
import { getUser, getRefreshToken, clearAuthData } from "../utils/auth";
import { logout } from "../services/authService";
import { User, Mail, Shield, Building, CheckCircle, Calendar, Edit2, Lock, LogOut, Trash2 } from "lucide-react";
import { useState } from "react";

export default function ProfilePage() {
  const navigate = useNavigate();
  const user = getUser();
  const [loggingOut, setLoggingOut] = useState(false);

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
                <span className="inline-flex items-center px-2.5 py-0.5 rounded text-xs font-semibold uppercase tracking-wide bg-slate-100 text-slate-700">
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
          <button className="flex items-center gap-3 px-4 py-3 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors text-sm font-semibold text-slate-700">
            <Edit2 className="w-4 h-4 text-slate-400" />
            Edit Profile
          </button>
          <button className="flex items-center gap-3 px-4 py-3 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors text-sm font-semibold text-slate-700">
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
      </div>
    </DashboardLayout>
  );
}
