"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Input } from "./ui/Input";
import { Button } from "./ui/Button";
import { login } from "../lib/api";
import { saveToken } from "../lib/auth";

export function LoginForm() {
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      const { token } = await login(identifier, password);
      if (token) {
        saveToken(token);
        // For now, we redirect to a generic dashboard.
        // A full implementation would involve fetching user role
        // and redirecting accordingly (e.g., /admin or /app/dashboard)
        router.push("/dashboard");
      } else {
        // Handle case where token is not returned
        setError("Login successful, but no token was provided.");
      }
    } catch (err) {
      setError("Failed to login. Please check your credentials.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-black-900 text-white">
      <div className="w-full max-w-md space-y-6 rounded-lg bg-black-900 p-6 shadow-lg border">
        <div>
          <h1 className="text-sm font-black tracking-[0.4em] text-white cursor-default uppercase text-center">
            bank<span className="text-blue-500">cursor</span>
          </h1>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="space-y-4 rounded-md shadow-sm">
            <Input
              id="identifier"
              name="identifier"
              type="text"
              autoComplete="username"
              required
              label="Email, CPF, or Account Number"
              value={identifier}
              onChange={(e) => setIdentifier(e.target.value)}
            />
            <Input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
              label="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <div>
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Signing in..." : "Sign in"}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
