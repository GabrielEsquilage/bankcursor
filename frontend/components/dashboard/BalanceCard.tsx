"use client";

interface BalanceCardProps {
  name: string;
  accountNumber: string;
  balance: number;
}

export function BalanceCard({ name, accountNumber, balance }: BalanceCardProps) {
  return (
    <div className="bg-[#050505] rounded-lg p-8 border border-white/10 relative overflow-hidden">
      <div className="flex flex-col gap-12">
        <div className="flex justify-between items-start">
          <div className="space-y-1">
            <p className="text-[9px] font-bold uppercase tracking-[0.3em] text-white/30">Account Holder</p>
            <h2 className="text-lg font-medium text-white tracking-tight">{name}</h2>
          </div>
          <div className="text-right space-y-1">
            <p className="text-[9px] font-bold uppercase tracking-[0.3em] text-white/30">Reference</p>
            <p className="text-xs font-mono text-white/60 tracking-tighter">{accountNumber}</p>
          </div>
        </div>

        <div>
          <p className="text-[9px] font-bold uppercase tracking-[0.3em] text-blue-500 mb-3">Available Balance</p>
          <div className="flex items-baseline gap-4">
            <span className="text-4xl font-semibold tracking-tighter text-white font-mono">
              <span className="text-xl font-light text-white/20 mr-2">BRL</span>
              {balance.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
            </span>
          </div>
        </div>
      </div>
      
      {/* Decorative subtle corner accent */}
      <div className="absolute top-0 right-0 w-16 h-16 bg-white/[0.02] rotate-45 translate-x-8 -translate-y-8 border-l border-b border-white/5" />
    </div>
  );
}
