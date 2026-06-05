import axios from "axios";
import { getAccessToken } from "../utils/auth";

const API_BASE_URL = "http://localhost:8081/api/v1";

export const getMyClaim = (sortBy, sortDir, pageNumber) => {
  const token = getAccessToken();

  return axios.get(`${API_BASE_URL}/claims/my`, {
    params: {
      sortBy: sortBy,
      sortDir: sortDir,
      pageNumber: pageNumber,
    },
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
};

export const getClaimById = (claimId) => {
  const token = getAccessToken();
  return axios.get(`${API_BASE_URL}/claims/${claimId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
};

export const addClaim = (payload) => {
  const token = getAccessToken();
  return axios.post(
    `http://localhost:8081/api/v1/claims`,

    payload,
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );
};
