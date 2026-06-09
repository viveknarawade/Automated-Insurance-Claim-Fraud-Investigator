import axios from 'axios'
import { getAccessToken, clearAuthData } from '../utils/auth'

const api = axios.create({
  baseURL: "http://localhost:8081/api/v1",
  headers: {
    "Content-Type": "application/json",
  },
});

api.interceptors.request.use(
  (config) => {
    const token = getAccessToken()
    if (token) config.headers.Authorization = `Bearer ${token}`
    return config
  },
  (error) => Promise.reject(error),
)

api.interceptors.response.use(
  (res) => res,
  (error) => {
    if (error.response?.status === 401) {
      const hadToken = !!getAccessToken()
      const onLoginPage = window.location.pathname === '/' || window.location.pathname === '/login'
      // Only wipe session and redirect if there was an active token (session expiry)
      // and we're not already on the login page (prevents redirect loops)
      if (hadToken && !onLoginPage) {
        clearAuthData()
        console.log('Session expired. Redirecting to login...')
        window.location.href = '/'
      }
    }
    return Promise.reject(error)
  },
)

export default api
