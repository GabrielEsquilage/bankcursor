const API_URL = "http://localhost:4000/api";

export async function login(identifier: string, password: string): Promise<{ token: string | null }> {
  const res = await fetch(`${API_URL}/users/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ identifier, password }),
  });

  if (!res.ok) {
    // You might want to handle different error statuses differently
    throw new Error("Failed to login");
  }

  const authorizationHeader = res.headers.get("authorization");
  if (!authorizationHeader) {
    throw new Error("No authorization token found in response");
  }

  const token = authorizationHeader.split("Bearer ")[1];
  return { token: token || null };
}
