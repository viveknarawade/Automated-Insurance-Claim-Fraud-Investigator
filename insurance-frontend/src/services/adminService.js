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

/** Get all claims for admin */
export const getAllClaimsAdmin = (pageNo = 0, pageSize = 20, sortBy = "CREATED_AT", sortDir = "DESC") =>
  api.get("/admin/claims", {
    params: { pageNumber: pageNo, pageSize, sortBy, sortDir },
  });
