import { Routes, Route, Navigate } from 'react-router-dom'

import LoginPage from './pages/LoginPage'
// import RegisterPage from "./pages/RegisterPage";
import CustomerDashboard from "./pages/CustomerDashboard";
import AdminDashboard from "./pages/AdminDashboard";
import InvestigatorDashboard from "./pages/InvestigatorDashboard";

function App() {
  return (
    <Routes>
      <Route path="/" element={<LoginPage />} />
      {/* <Route path="/register" element={<RegisterPage />} /> */}
      <Route path="/customer" element={<CustomerDashboard />} />
      <Route path="/admin" element={<AdminDashboard />} />
      <Route path="/investigator" element={<InvestigatorDashboard />} />
    </Routes>
  );
}

export default App;