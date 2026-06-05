import { useState } from "react";
import { login } from "../services/authService";
import { saveAuthData } from "../utils/auth";
import { Link, useNavigate } from "react-router-dom";

import { ShieldCheck, Eye, EyeOff, Loader2 } from "lucide-react";

function LoginPage() {
  const [form, setForm] = useState({ email: "", password: "" });
  const [showPwd, setShowPwd] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const set = (k) => (e) => setForm((p) => ({ ...p, [k]: e.target.value }));

  // const handleLogin = async () => {
  //   setFeedbackMessage("");
  //   setIsError(false);

  //   const payload = {
  //     email,
  //     password,
  //   };

  //   try {
  //     const res = await login(payload);

  //     setFeedbackMessage(res.data.message);

  //     saveAuthData(
  //       res.data.data.accessToken,
  //       res.data.data.refreshToken,
  //       res.data.data.user,
  //     );

  //     const role = res.data.data.user.role;

  //     if (role === "ADMIN") {
  //       navigate("/admin");
  //     } else if (role === "INVESTIGATOR") {
  //       navigate("/investigator");
  //     } else {
  //       navigate("/customer");
  //     }
  //   } catch (err) {
  //     setIsError(true);

  //     setFeedbackMessage(err.response?.data?.message || "Login failed");
  //   }
  // };

  const handleSubmit = async (event) => {
    event.preventDefault(); // Browser refresh is stopped
    setError("");
    setLoading(true);
    try {
      const res = await login(form)
      handleLoginSuccess(res.data.data, navigate)
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed. Please check your credentials.')
    } finally {
      setLoading(false)
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div>
          {/* Brand */}
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-12 h-12 bg-indigo-600 rounded-xl mb-4">
              <ShieldCheck size={24} className="text-white" />
            </div>
            <h1 className="text-2xl font-bold text-slate-900">FraudGuard</h1>
          </div>

          <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-8">
            {/*Error  */}
            {error && (
              <div className="mb-4 px-4 py-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
                {error}
              </div>
            )}

            {/* login from */}
            <form onSubmit={handleSubmit} className="space-y-5">
              <div>
                <h3>Sign in</h3>
                <p>Access your FraudGuard workspace</p>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">
                  Email
                </label>
                <input
                  type="email"
                  required
                  value={form.email}
                  onChange={set("email")}
                  placeholder="you@example.com"
                  className="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">
                  Password
                </label>
                <div className="relative">
                  <input
                    type={showPwd ? "text" : "password"}
                    required
                    value={form.password}
                    onChange={set("password")}
                    placeholder="••••••••"
                    className="w-full px-3.5 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPwd((p) => !p)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                  >
                    {showPwd ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
                <div className="flex justify-end mt-1">
                  <Link
                    to="/forgot-password"
                    className="text-xs text-indigo-600 hover:underline"
                  >
                    Forgot password?
                  </Link>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full flex items-center justify-center gap-2 py-2.5 px-4 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 disabled:opacity-60 disabled:cursor-not-allowed transition-colors"
              >
                {loading && <Loader2 size={16} className="animate-spin" />}
                {loading ? "Signing in…" : "Sign in"}
              </button>
            </form>

            <p className="text-center text-sm text-slate-500 mt-6">
              Don't have an account?{" "}
              <Link
                to="/register"
                className="text-indigo-600 font-medium hover:underline"
              >
                Register
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>

    // <div className="max-w-md mx-auto p-6 bg-white rounded-xl shadow-md space-y-4 border border-gray-100">
    //   {feedbackMessage && (
    //     <div
    //       className={`p-3 rounded text-sm ${
    //         isError
    //           ? "bg-red-50 text-red-700 border border-red-200"
    //           : "bg-green-50 text-green-700 border border-green-200"
    //       }`}
    //     >
    //       {feedbackMessage}
    //     </div>
    //   )}

    //   <div className="flex flex-col gap-1.5">
    //     <label
    //       htmlFor="email-field"
    //       className="text-sm font-medium text-gray-700"
    //     >
    //       Email
    //     </label>
    //     <input
    //       id="email-field"
    //       type="email"
    //       value={email}
    //       onChange={(e) => setEmail(e.target.value)}
    //       className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
    //       placeholder="you@example.com"
    //     />
    //   </div>

    //   <div className="flex flex-col gap-1.5">
    //     <label
    //       htmlFor="password-field"
    //       className="text-sm font-medium text-gray-700"
    //     >
    //       Password
    //     </label>
    //     <input
    //       id="password-field"
    //       type="password"
    //       value={password}
    //       onChange={(e) => setPassword(e.target.value)}
    //       className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
    //       placeholder="••••••••"
    //     />
    //   </div>

    //   <button
    //     type="button"
    //     onClick={handleLogin}
    //     className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-200"
    //   >
    //     Login
    //   </button>
    // </div>
  );
}

export default LoginPage;
