export interface Account {
  number: string;
  balance: number | string;
}
export interface User {
  name: string;
  account: Account | null;
  email: string;
}

export interface ApiResponse {
  data: User;
}

export interface Transaction {
  id: string;
  type: "deposit" | "withdrawal" | "transfer";
  amount: number;
  date: string;
}
