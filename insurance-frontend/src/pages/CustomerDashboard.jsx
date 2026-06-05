import { useEffect, useState } from "react";
import { getClaimById, getMyClaim, addClaim } from "../services/claimService";

function CustomerDashboard() {
  const [claims, setClaims] = useState([]);
  const [claimId, setClaimId] = useState("");
  const [incidentCity, setincidentCity] = useState("");
  const [incidentState, setIncidentState] = useState("");
  const [claimType, setClaimType] = useState("");
  const [claimAmount, setClaimAmount] = useState("");
  const [description, setDescription] = useState("");
  const [incidentDate, setIncidentDate] = useState("");
  const [incidentAddress, setIncidentAddress] = useState("");
  const [claim, setClaim] = useState(null);
  const [sortBy, setSortBy] = useState("INCIDENT_DATE");
  const [sortDir, setSortDir] = useState("DESC");
  const [currentPage, setCurrentPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);

 function CustomInput({ val, onChange, placeholder }) {
  return (
    <input
      value={val}
      style={styles.input}
      onChange={onChange} 
      placeholder={placeholder}
    />
  );
}
  useEffect(() => {
    fetchClaims();
  }, [sortBy, sortDir, currentPage]);

  const fetchClaims = async () => {
    try {
      const res = await getMyClaim(sortBy, sortDir, currentPage);
      const pageData = res.data.data;
      setClaims(pageData.content || []);
      setTotalPages(pageData.totalPages || 0);
    } catch (err) {
      console.error(err.response?.data?.message);
    }
  };

  const fetchClaimById = async () => {
    if (!claimId) {
      alert("Enter claim id");
      return;
    }
    try {
      const res = await getClaimById(claimId);
      setClaim(res.data.data);
    } catch (err) {
      console.error(err.response?.data?.message);
    }
  };

   const handleAddClaim = async () => {
    // Fix: Added missing 'const' keyword to prevent global scope leakage
    const payload = {
      claimType,
      claimAmount,
      description,
      incidentDate,
      incidentAddress,
      incidentCity,
      incidentState,
    };
    
    try {
      const res = await addClaim(payload);
      setClaim(res.data.data);
      alert("Claim added successfully!");
    } catch (err) {
      console.error(err.response?.data?.message || "Failed to add claim");
    }
  };
  // --- Centralised Design Styles ---
  const styles = {
    container: {
      maxWidth: "800px",
      margin: "30px auto",
      padding: "20px",
      fontFamily: "'Segoe UI', Roboto, sans-serif",
      color: "#333",
      backgroundColor: "#f9f9f9",
      borderRadius: "12px",
      boxShadow: "0 4px 6px rgba(0,0,0,0.05)",
    },
    title: {
      fontSize: "24px",
      fontWeight: "600",
      marginBottom: "20px",
      color: "#111",
    },
    subtitle: {
      fontSize: "18px",
      fontWeight: "600",
      margin: "25px 0 15px 0",
      color: "#222",
    },
    controlGroup: {
      display: "flex",
      gap: "12px",
      marginBottom: "20px",
      flexWrap: "wrap",
    },
    select: {
      padding: "8px 12px",
      fontSize: "14px",
      borderRadius: "6px",
      border: "1px solid #ccc",
      backgroundColor: "#fff",
      cursor: "pointer",
      outline: "none",
    },
    listContainer: {
      display: "flex",
      flexDirection: "column",
      gap: "12px",
      marginBottom: "20px",
    },
    card: {
      padding: "16px",
      backgroundColor: "#fff",
      borderRadius: "8px",
      border: "1px solid #e0e0e0",
      boxShadow: "0 2px 4px rgba(0,0,0,0.02)",
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
    },
    cardInfo: {
      margin: 0,
    },
    claimNum: {
      fontSize: "16px",
      fontWeight: "600",
      margin: "0 0 4px 0",
      color: "#0056b3",
    },
    statusBadge: (status) => ({
      padding: "4px 10px",
      borderRadius: "12px",
      fontSize: "12px",
      fontWeight: "bold",
      textTransform: "uppercase",
      backgroundColor:
        status === "APPROVED"
          ? "#e6f4ea"
          : status === "UNDER_REVIEW"
            ? "#fef7e0"
            : "#fce8e6",
      color:
        status === "APPROVED"
          ? "#137333"
          : status === "UNDER_REVIEW"
            ? "#b06000"
            : "#c5221f",
    }),
    paginationRow: {
      display: "flex",
      alignItems: "center",
      gap: "15px",
      marginTop: "15px",
    },
    button: {
      padding: "8px 16px",
      fontSize: "14px",
      fontWeight: "500",
      borderRadius: "6px",
      border: "none",
      backgroundColor: "#007bff",
      color: "#fff",
      cursor: "pointer",
      transition: "background-color 0.2s",
    },
    disabledButton: {
      backgroundColor: "#e0e0e0",
      color: "#a1a1a1",
      cursor: "not-allowed",
    },
    divider: {
      border: "0",
      height: "1px",
      background: "#e0e0e0",
      margin: "30px 0",
    },
    searchRow: {
      display: "flex",
      gap: "10px",
      marginBottom: "20px",
    },
    input: {
      padding: "10px",
      fontSize: "14px",
      borderRadius: "6px",
      border: "1px solid #ccc",
      width: "200px",
      outline: "none",
    },
    detailBox: {
      padding: "20px",
      backgroundColor: "#fff",
      borderRadius: "8px",
      border: "2px solid #007bff",
      marginTop: "15px",
    },
  };

  return (
    <div style={styles.container}>
      <h2 style={styles.title}>My Claims</h2>

      {/* Sorting Selectors */}
      <div style={styles.controlGroup}>
        <select
          value={sortBy}
          style={styles.select}
          onChange={(e) => {
            setSortBy(e.target.value);
            setCurrentPage(0);
          }}
        >
          <option value="CREATED_AT">Created At</option>
          <option value="CLAIM_AMOUNT">Claim Amount</option>
          <option value="INCIDENT_DATE">Incident Date</option>
          <option value="CLAIM_STATUS">Claim Status</option>
        </select>

        <select
          value={sortDir}
          style={styles.select}
          onChange={(e) => {
            setSortDir(e.target.value);
            setCurrentPage(0);
          }}
        >
          <option value="ASC">ASC</option>
          <option value="DESC">DESC</option>
        </select>
      </div>

      {/* Claims Grid List */}
      <div style={styles.listContainer}>
        {claims.map((claimItem) => (
          <div key={claimItem.claimId} style={styles.card}>
            <div style={styles.cardInfo}>
              <h3 style={styles.claimNum}>{claimItem.claimNumber}</h3>
              <small style={{ color: "#777" }}>ID: {claimItem.claimId}</small>
            </div>
            <span style={styles.statusBadge(claimItem.claimStatus)}>
              {claimItem.claimStatus?.replace("_", " ")}
            </span>
          </div>
        ))}
      </div>

      {/* Pagination Actions */}
      <div style={styles.paginationRow}>
        <button
          disabled={currentPage === 0}
          style={{
            ...styles.button,
            ...(currentPage === 0 ? styles.disabledButton : {}),
          }}
          onClick={() => setCurrentPage(currentPage - 1)}
        >
          Previous
        </button>

        <span style={{ fontSize: "14px", color: "#666" }}>
          Page {currentPage + 1} of {totalPages || 1}
        </span>

        <button
          disabled={currentPage >= totalPages - 1}
          style={{
            ...styles.button,
            ...(currentPage >= totalPages - 1 ? styles.disabledButton : {}),
          }}
          onClick={() => setCurrentPage(currentPage + 1)}
        >
          Next
        </button>
      </div>

      <hr style={styles.divider} />

      {/* Search Bar Section */}
      <h3 style={styles.subtitle}>Search Claim Details</h3>
      <div style={styles.searchRow}>
        <input
          value={claimId}
          style={styles.input}
          onChange={(e) => setClaimId(e.target.value)}
          placeholder="Enter Claim ID"
        />
        <button onClick={fetchClaimById} style={styles.button}>
          Get Claim
        </button>
      </div>

      {/* Single Claim Detail Container */}
      {claim && (
        <div style={styles.detailBox}>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              marginBottom: "10px",
            }}
          >
            <h2 style={{ ...styles.claimNum, fontSize: "20px" }}>
              {claim.claimNumber}
            </h2>
            <span style={styles.statusBadge(claim.claimStatus)}>
              {claim.claimStatus?.replace("_", " ")}
            </span>
          </div>
          <p style={{ margin: "5px 0", fontSize: "14px" }}>
            <strong>Description:</strong>{" "}
            {claim.description || "No description provided."}
          </p>
          <p style={{ margin: "5px 0", fontSize: "14px" }}>
            <strong>City:</strong> {claim.incidentCity}
          </p>
          <p style={{ margin: "5px 0", fontSize: "14px" }}>
            <strong>Amount:</strong> ₹{claim.claimAmount}
          </p>
        </div>
      )}

      <hr style={styles.divider} />
    <div style={{ display: "flex", flexDirection: "column", gap: "10px", maxWidth: "400px" }}>
      {/* 2. Pass down unique value, tracking handler, and placeholder text to each input */}
      <CustomInput 
        val={claimType} 
        onChange={(e) => setClaimType(e.target.value)} 
        placeholder="Enter Claim Type (e.g. CAR)" 
      />
      <CustomInput 
        val={claimAmount} 
        onChange={(e) => setClaimAmount(e.target.value)} 
        placeholder="Enter Claim Amount" 
      />
      <CustomInput 
        val={incidentAddress} 
        onChange={(e) => setIncidentAddress(e.target.value)} 
        placeholder="Enter Incident Address" 
      />
      <CustomInput 
        val={incidentCity} 
        onChange={(e) => setincidentCity(e.target.value)} 
        placeholder="Enter Incident City" 
      />
      <CustomInput 
        val={incidentDate} 
        onChange={(e) => setIncidentDate(e.target.value)} 
        placeholder="Enter Incident Date (YYYY-MM-DD)" 
      />
      <CustomInput 
        val={incidentState} 
        onChange={(e) => setIncidentState(e.target.value)} 
        placeholder="Enter Incident State" 
      />
      <CustomInput 
        val={description} 
        onChange={(e) => setDescription(e.target.value)} 
        placeholder="Enter Short Description" 
      />

      <button onClick={handleAddClaim} style={styles.button}>
        Add Claim
      </button>
    </div>
    </div>
  );
}

export default CustomerDashboard;
