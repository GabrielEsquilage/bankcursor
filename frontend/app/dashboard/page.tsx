"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { isLoggedIn, removeToken, getToken } from "../../lib/auth";
import { Button } from "../../components/ui/Button";
import { BalanceCard } from "../../components/dashboard/BalanceCard";
import { TransactionsList } from "../../components/dashboard/TransactionsList";
import { QuickAction } from "../../components/dashboard/QuickAction";
import { getCurrentUser } from "../../lib/api";

interface Transaction {
  id: string;
  type: "deposit" | "withdraw" | "transfer";
  amount: number;
  date: string;
  description: string;
}

interface UserData {
  name: string;
  accountNumber: string;
  balance: number;
}

export default function DashboardPage() {
  const router = useRouter();
  const [userData, setUserData] = useState<UserData | null>(null);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const token = getToken();
    if (!token) {
      router.push("/login");
      return;
    }

    const fetchData = async () => {
      try {
        const response = await getCurrentUser(token);
        const user = response.data;

        setUserData({
          name: user.name,
          accountNumber: user.account?.account_number || "Dado Indisponível",
          balance: user.account?.balance || 0,
        });

        setTransactions([
          {
            id: "1",
            type: "deposit",
            amount: 1500.0,
            date: "2024-03-16",
            description: "Venda de Serviços",
          },
          {
            id: "2",
            type: "withdraw",
            amount: 120.5,
            date: "2024-03-15",
            description: "Restaurante Gourmet",
          },
          {
            id: "3",
            type: "transfer",
            amount: 450.0,
            date: "2024-03-14",
            description: "Aluguel Março",
          },
        ]);
      } catch (error) {
        console.error("Error fetching data:", error);
        removeToken();
        router.push("/login");
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [router]);

  const handleLogout = () => {
    removeToken();
    router.push("/");
  };

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-black text-white font-mono">
        <div className="flex flex-col items-center gap-6">
          <div className="w-8 h-8 border border-white/10 border-t-white rounded-full animate-spin" />
          <p className="text-sm font-bold uppercase tracking-[0.5em] text-white/40">
            Sincronizando
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black text-white selection:bg-blue-500/30 font-sans">
      {/* Top Navbar */}
      <nav className="border-b border-white/50 bg-black sticky top-0 z-50">
        <div className="max-w-10xl mx-auto px-10 h-14 flex items-center justify-between">
          <div className="flex items-center gap-16">
            <h1 className="text-sm font-black tracking-[0.4em] text-white cursor-default uppercase">
              bank<span className="text-blue-500">cursor</span>
            </h1>
            <div className="hidden md:flex items-center gap-10">
              <span className="text-xs font-bold uppercase tracking-[0.2em] text-white border-b border-white pb-1">
                Monitor
              </span>
              <span className="text-xs font-bold uppercase tracking-[0.2em] text-white/40 hover:text-white transition-colors cursor-pointer">
                Ativos
              </span>
              <span className="text-xs font-bold uppercase tracking-[0.2em] text-white/40 hover:text-white transition-colors cursor-pointer">
                Ordens
              </span>
            </div>
          </div>
          <div className="flex items-center gap-8">
            <div className="flex items-center gap-3">
              <div className="text-right">
                <p className="text-xs font-bold text-white uppercase tracking-wider">
                  {userData?.name.split(" ")[0]}
                </p>
                <p className="text-[10px] font-bold text-emerald-500 uppercase tracking-tighter">
                  Verified Account
                </p>
              </div>
              <div className="w-12 h-9 rounded-sm bg-white/5 border border-white/10 flex items-center justify-center font-bold text-[12px] text-blue-500">
                {userData?.name.charAt(0)}
              </div>
            </div>
            <button
              onClick={handleLogout}
              className="text-[11px] font-bold uppercase tracking-widest text-white/30 hover:text-white transition-colors"
            >
              SAIR
            </button>
          </div>
        </div>
      </nav>

      <main className="max-w-10xl mx-auto px-10 py-12">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          {/* Left Column: Balance & Actions */}
          <div className="lg:col-span-8 space-y-6">
            <BalanceCard
              name={userData?.name || ""}
              accountNumber={userData?.accountNumber || ""}
              balance={userData?.balance || 0}
            />

            <div className="grid grid-cols-2 md:grid-cols-4 gap-px bg-white/10 border border-white/30 rounded-lg overflow-hidden">
              <QuickAction label="Pagamentos" icon="🧾" />
              <QuickAction label="Pix" icon="💠" />
              <QuickAction label="TED/DOC" icon="💸" />
              <QuickAction label="Câmbio" icon="💱" />
            </div>
          </div>

          {/* Right Column: Transactions */}
          <div className="lg:col-span-4 sticky top-24">
            <TransactionsList transactions={transactions} />
          </div>
        </div>
      </main>
    </div>
  );
}
