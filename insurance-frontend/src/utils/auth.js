export const saveAuthData = (
  accessToken,
  refreshToken,
  user
) => {

  localStorage.setItem(
    "accessToken",
    accessToken
  );

  localStorage.setItem(
    "refreshToken",
    refreshToken
  );

  localStorage.setItem(
    "user",
    JSON.stringify(user)
  );
};

export const getUser = () => {
  return JSON.parse(
    localStorage.getItem("user")
  );
};

export const getAccessToken = () => {
  return localStorage.getItem("accessToken");
};

export const logout = () => {
  localStorage.clear();
};