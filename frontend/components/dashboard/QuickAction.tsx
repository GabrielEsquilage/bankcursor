"use client";

interface QuickActionProps {
  label: string;
  icon: string;
  onClick?: () => void;
}

export function QuickAction({ label, icon, onClick }: QuickActionProps) {
  return (
    <button
      onClick={onClick}
      className="group flex items-center gap-4 p-5 bg-black hover:bg-white/3 transition-all duration-300"
    >
      <div className="w-8 h-8 flex items-center justify-center text-lg grayscale opacity-40 group-hover:grayscale-0 group-hover:opacity-100 transition-all duration-500">
        {icon}
      </div>
      <span className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/30 group-hover:text-blue-500 transition-colors">
        {label}
      </span>
    </button>
  );
}
