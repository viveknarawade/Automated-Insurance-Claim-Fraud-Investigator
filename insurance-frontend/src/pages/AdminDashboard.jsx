import { useEffect, useState } from "react";
import { getClaimById, getMyClaim } from "../services/claimService";

function ClaimCard({ claimAmount, claimId, claimNumber, claimStatus, claimType, createdAt, fraudStatus, incidentCity, incidentDate }) {
  return (
    <div style={{ border: "1px solid #ccc", margin: "10px 0", padding: "10px" }}>
      <h3>Amount: {claimAmount}</h3>
      <h3>ID: {claimId}</h3>
      <h3>Number: {claimNumber}</h3>
      <h3>Status: {claimStatus}</h3>
      <h3>Type: {claimType}</h3>
      <h3>Created: {createdAt}</h3>
      <h3>Fraud: {fraudStatus}</h3>
      <h3>City: {incidentCity}</h3>
      <h3>Date: {incidentDate}</h3>
    </div>
  );
}

function ClaimDetailCard({ claim }) {
  if (!claim || !claim.claimId) return null; 
  
  return (
    <div style={{ background: "#f0f0f0", padding: "15px", margin: "15px 0" }}>
      <h2>-- Claim Detail Details --</h2>
      <h3>Amount: {claim.claimAmount}</h3>
      <h3>ID: {claim.claimId}</h3>
      <h3>Number: {claim.claimNumber}</h3>
      <h3>Status: {claim.claimStatus}</h3>
      <h3>Type: {claim.claimType}</h3>
      <h3>Created: {claim.createdAt}</h3>
      <h3>Fraud Status: {claim.fraudStatus}</h3>
      <h3>Address: {claim.incidentAddress}, {claim.incidentCity}, {claim.incidentState}</h3>
      <h3>Date: {claim.incidentDate}</h3>
      <h3>Description: {claim.description}</h3>
      <h3>Review Notes: {claim.reviewNotes}</h3>
    </div>
  );
}

function CustomerDashboard() {
  const [claimId, setClaimId] = useState("");
  const [claims, setClaims] = useState([]);
  const [claim, setClaim] = useState({});
  const [totalPages, setTotalPages] = useState(0); 

  // New States for Sorting and Pagination
  const [sortBy, setSortBy] = useState("INCIDENT_DATE");
  const [sortDir, setSortDir] = useState("DESC");
  const [currentPage, setCurrentPage] = useState(1);

  // Updated to use state variables if arguments are not manually passed
  const handleMyClaim = async (field = sortBy, direction = sortDir, page = currentPage) => {
    try {
      const res = await getMyClaim(field, direction, page);
      const list = res.data?.data.content || [];
      const total = res.data?.data.totalPages || 0; 
      
      setClaims(list);
      setTotalPages(total); 
    } catch (err) {
      console.error(err.response?.data?.message || "get my claim failed");
    }
  };

  const handleClaimById = async () => {
    if (!claimId) return alert("Please enter a claim ID first!");
    try {
      const res = await getClaimById(claimId);
      const data = res.data?.data || {};
      setClaim(data);
    } catch (err) {
      console.error(err.response?.data?.message || "get claim by id failed");
    }
  };

  // Automatically re-fetch data whenever sort options or page numbers change
  useEffect(() => {
    handleMyClaim(sortBy, sortDir, currentPage);
  }, [sortBy, sortDir, currentPage]);

  return (
    <>
      <div style={{ display: "flex", gap: "15px", marginBottom: "15px", alignItems: "center" }}>
        {/* Dropdown 1: Sort Options mapped to your Backend Enums */}
        <div>
          <label htmlFor="sortField">Sort By: </label>
          <select 
            id="sortField"
            value={sortBy} 
            onChange={(e) => {
              setSortBy(e.target.value);
              setCurrentPage(1); // Reset to page 1 on sorting change
            }}
          >
            <option value="CREATED_AT">Created At</option>
            <option value="CLAIM_AMOUNT">Claim Amount</option>
            <option value="INCIDENT_DATE">Incident Date</option>
            <option value="CLAIM_STATUS">Claim Status</option>
          </select>
        </div>

        {/* Dropdown 2: Sort Direction */}
        <div>
          <label htmlFor="sortDirection">Direction: </label>
          <select 
            id="sortDirection"
            value={sortDir} 
            onChange={(e) => {
              setSortDir(e.target.value);
              setCurrentPage(1); // Reset to page 1 on direction change
            }}
          >
            <option value="ASC">Ascending (ASC)</option>
            <option value="DESC">Descending (DESC)</option>
          </select>
        </div>

        <button onClick={() => handleMyClaim(sortBy, sortDir, currentPage)}>
          Refresh Claims
        </button>
      </div>

      <div>
        <strong>Total Pages available: {totalPages}</strong>
        <p>Current Page: {currentPage}</p>
      </div>

      <div>
        {claims.length > 0 ? (
          claims.map((claimObj) => (
            <ClaimCard key={claimObj.claimId} {...claimObj} />
          ))
        ) : (
          <p>No claims found. Adjust your sorting or click Refresh.</p>
        )}
      </div>

      {/* Simple Pagination Buttons */}
      {totalPages > 1 && (
        <div style={{ display: "flex", gap: "10px", margin: "15px 0" }}>
          <button 
            disabled={currentPage === 1} 
            onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
          >
            Previous
          </button>
          <button 
            disabled={currentPage === totalPages} 
            onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
          >
            Next
          </button>
        </div>
      )}

      <div style={{ marginTop: "30px", borderTop: "2px solid #eee", paddingTop: "15px" }}>
        <input
          type="text"
          value={claimId}
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
          placeholder="Enter Claim ID (e.g. 11)"
          onChange={(e) => setClaimId(e.target.value)}
        />
        
        <button onClick={handleClaimById}>Get claim by ID</button>
      </div>

      {claim && claim.claimId && <ClaimDetailCard claim={claim} />}
    </>
  );
}

export default CustomerDashboard;
