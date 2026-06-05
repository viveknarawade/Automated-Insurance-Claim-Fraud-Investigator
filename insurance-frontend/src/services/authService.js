import axios from "axios";

const API_URL =
  "http://localhost:8081/api/v1/auth";

export const login = (payload) => {
  return axios.post(
    `${API_URL}/login`,
    payload
  );
};