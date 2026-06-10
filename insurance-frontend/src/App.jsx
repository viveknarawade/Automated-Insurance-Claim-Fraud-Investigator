import { Routes, Route, Navigate } from 'react-router-dom'

import LoginPage from './pages/auth/LoginPage'
// import RegisterPage from "./pages/auth/RegisterPage";
import CustomerDashboard from "./pages/customer/CustomerDashboard";
import MyClaimPage from './pages/customer/MyClaimPage';
import ClaimDetailPage from './pages/customer/ClaimDetailPage';
import SubmitNewClaim from './pages/customer/SubmitNewClaim';
import ProfilePage from './pages/common/ProfilePage';
import NotificationPage from './pages/common/NotificationPage';
import AdminDashboard from "./pages/admin/AdminDashboard";
import AdminClaimsPage from "./pages/admin/AdminClaimsPage";
import AdminClaimDetailPage from "./pages/admin/AdminClaimDetailPage";
import AdminWorkloadPage from "./pages/admin/AdminWorkloadPage";
import AdminTenantsPage from "./pages/admin/AdminTenantsPage";
import AdminUsersPage from "./pages/admin/AdminUsersPage";
import AdminFraudRulesPage from "./pages/admin/AdminFraudRulesPage";
import AdminWorkflowPage from "./pages/admin/AdminWorkflowPage";
import AdminLogsPage from "./pages/admin/AdminLogsPage";
import InvestigatorDashboard from "./pages/investigator/InvestigatorDashboard";
import InvestigatorClaimsPage from "./pages/investigator/InvestigatorClaimsPage";
import InvestigatorClaimDetailPage from "./pages/investigator/InvestigatorClaimDetailPage";

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
      <Route path="/admin/claims" element={<AdminClaimsPage />} />
      <Route path="/admin/claims/:claimId" element={<AdminClaimDetailPage />} />

      <Route path="/admin/workload" element={<AdminWorkloadPage />} />
      <Route path="/admin/tenants" element={<AdminTenantsPage />} />
      <Route path="/admin/users" element={<AdminUsersPage />} />
      <Route path="/admin/rules" element={<AdminFraudRulesPage />} />
      <Route path="/admin/workflow" element={<AdminWorkflowPage />} />
      <Route path="/admin/logs" element={<AdminLogsPage />} />
      <Route path="/admin/profile" element={<ProfilePage />} />

      {/* Investigator */}
      <Route path="/investigator/dashboard" element={<InvestigatorDashboard />} />
      <Route path="/investigator/claims" element={<InvestigatorClaimsPage />} />
      <Route path="/investigator/claims/:claimId" element={<InvestigatorClaimDetailPage />} />
      <Route path="/investigator/notifications" element={<NotificationPage />} />
      <Route path="/investigator/profile" element={<ProfilePage />} />
    </Routes>
  );
}

export default App;