import api from "./api";

/** Dashboard stats */
export const getAdminDashboard = () =>
  api.get("/admin/dashboard");

/** Investigator workload list */
export const getInvestigatorsWorkload = () =>
  api.get("/admin/investigators/workload");

/** Assign investigator to a claim */
export const assignInvestigator = (claimId, investigatorId) =>
  api.patch(`/admin/claims/${claimId}/assign-investigator`, { investigatorId });

/** Approve a claim */
export const approveClaim = (claimId, decisionNotes) =>
  api.patch(`/admin/claims/${claimId}/approve`, { decisionNotes });

/** Reject a claim */
export const rejectClaim = (claimId, decisionNotes) =>
  api.patch(`/admin/claims/${claimId}/reject`, { decisionNotes });

/** Get all claims (admin sees all users' claims via the same paginated endpoint) */
export const getAllClaimsAdmin = (pageNo = 0, pageSize = 20, sortBy = "CREATED_AT", sortDir = "DESC") =>
  api.get("/claims/my", {
    params: { pageNo, pageSize, sortBy, sortDir },
  });
