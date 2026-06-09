import { Routes, Route, Navigate } from 'react-router-dom'

import LoginPage from './pages/LoginPage'
// import RegisterPage from "./pages/RegisterPage";
import CustomerDashboard from "./pages/CustomerDashboard";
import MyClaimPage from './pages/MyClaimPage';
import ClaimDetailPage from './pages/ClaimDetailPage';
import SubmitNewClaim from './pages/SubmitNewClaim';
import ProfilePage from './pages/ProfilePage';
import NotificationPage from './pages/NotificationPage';
import AdminDashboard from "./pages/AdminDashboard";
import AdminClaimDetailPage from "./pages/AdminClaimDetailPage";
import AdminAnalyticsPage from "./pages/AdminAnalyticsPage";
import AdminWorkloadPage from "./pages/AdminWorkloadPage";
import AdminTenantsPage from "./pages/AdminTenantsPage";
import AdminUsersPage from "./pages/AdminUsersPage";
import AdminFraudRulesPage from "./pages/AdminFraudRulesPage";
import AdminWorkflowPage from "./pages/AdminWorkflowPage";
import AdminLogsPage from "./pages/AdminLogsPage";
import InvestigatorDashboard from "./pages/InvestigatorDashboard";

function App() {
  return (
    <Routes>
      <Route path="/" element={<LoginPage />} />
      {/* <Route path="/register" element={<RegisterPage />} /> */}

      {/* Customer */}
      <Route path="/customer/dashboard" element={<CustomerDashboard />} />
      <Route path="/customer/claims" element={<MyClaimPage />} />
      <Route path="/customer/claims/new" element={<SubmitNewClaim />} />
      <Route path="/customer/claims/:claimId" element={<ClaimDetailPage />} />
      <Route path="/customer/notifications" element={<NotificationPage />} />
      <Route path="/customer/profile" element={<ProfilePage />} />

      {/* Admin */}
      <Route path="/admin/dashboard" element={<AdminDashboard />} />
      <Route path="/admin/claims/:claimId" element={<AdminClaimDetailPage />} />
      <Route path="/admin/analytics" element={<AdminAnalyticsPage />} />
      <Route path="/admin/workload" element={<AdminWorkloadPage />} />
      <Route path="/admin/tenants" element={<AdminTenantsPage />} />
      <Route path="/admin/users" element={<AdminUsersPage />} />
      <Route path="/admin/rules" element={<AdminFraudRulesPage />} />
      <Route path="/admin/workflow" element={<AdminWorkflowPage />} />
      <Route path="/admin/logs" element={<AdminLogsPage />} />

      {/* Investigator */}
      <Route path="/investigator/dashboard" element={<InvestigatorDashboard />} />
    </Routes>
  );
}

export default App;