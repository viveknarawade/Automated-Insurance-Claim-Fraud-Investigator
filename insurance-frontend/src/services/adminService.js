import axios from "axios";
import { getAccessToken } from "../utils/auth";

export const getDashboard = () => {
  const token = getAccessToken();

  return axios.get("http://localhost:8081/api/v1/admin/dashboard", {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
};

export const getInvestigatorsWorkload = () => {
  const token = getAccessToken();
  return axios.get(
    "http://localhost:8081/api/v1/admin/investigators/workload",
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );
};
