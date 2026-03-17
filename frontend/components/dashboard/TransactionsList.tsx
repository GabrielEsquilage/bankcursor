"use client";

interface Transaction {
  id: string;
  type: "deposit" | "withdraw" | "transfer";
  amount: number;
  date: string;
  description: string;
}

interface TransactionsListProps {
  transactions: Transaction[];
}

export function TransactionsList({ transactions }: TransactionsListProps) {
  return (
    <div className="bg-[#050505] rounded-lg p-8 border border-white/30 flex flex-col h-full">
      <div className="flex items-center justify-between mb-10">
        <h3 className="text-[10px] font-bold uppercase tracking-[0.3em] text-white/40">
          Log Activity
        </h3>
        <button className="text-[9px] font-bold uppercase tracking-widest text-blue-500 hover:text-white transition-colors border-b border-blue-500/20 pb-0.5">
          Download CSV
        </button>
      </div>

      <div className="space-y-6 grow">
        {transactions.map((t) => (
          <div
            key={t.id}
            className="flex items-center justify-between group cursor-default"
          >
            <div className="flex items-center gap-6">
              <div
                className={`w-[3px] h-8 transition-all duration-700 ${
                  t.type === "deposit"
                    ? "bg-emerald-500"
                    : "bg-white/20 group-hover:bg-rose-500"
                }`}
              />
              <div>
                <p className="text-xs font-medium text-white/80 group-hover:text-white transition-colors">
                  {t.description}
                </p>
                <p className="text-xs text-white/20 font-bold uppercase tracking-widest mt-1">
                  {new Date(t.date)
                    .toLocaleDateString("pt-BR", {
                      day: "2-digit",
                      month: "short",
                    })
                    .replace(".", "")}
                </p>
              </div>
            </div>

            <div className="text-right">
              <p
                className={`text-xs font-semibold tracking-tighter font-mono ${
                  t.type === "deposit" ? "text-emerald-500" : "text-white"
                }`}
              >
                {t.type === "deposit" ? "+" : "-"}{" "}
                {t.amount.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
