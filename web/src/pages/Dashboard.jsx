import React from 'react';
import { useNavigate } from 'react-router-dom';
import { LogOut, MonitorSmartphone } from 'lucide-react';

export default function Dashboard() {
  const navigate = useNavigate();
  const ip = localStorage.getItem('winpilot_ip') || 'Unknown';

  const handleLogout = () => {
    localStorage.removeItem('winpilot_token');
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-[var(--color-win-bg)] text-white flex flex-col">
      {/* Navbar */}
      <nav className="glass-panel px-6 py-4 flex items-center justify-between border-b border-white/10 sticky top-0 z-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#2D8CFF] to-[#1A75E6] flex items-center justify-center shadow-lg shadow-blue-500/20">
            <MonitorSmartphone className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="font-bold text-lg leading-tight">WinPilot Web</h1>
            <p className="text-xs text-white/50">Connected to {ip}</p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="flex items-center gap-2 px-4 py-2 rounded-lg bg-white/5 hover:bg-white/10 transition-colors text-sm font-medium"
        >
          <LogOut className="w-4 h-4" /> Disconnect
        </button>
      </nav>

      {/* Main Content Area */}
      <main className="flex-1 p-6 md:p-10">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-2xl font-bold mb-6">Dashboard Overview</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="glass-panel p-6 rounded-2xl flex flex-col items-center justify-center h-32 border-dashed border-white/20">
              <span className="text-white/40">System Monitor (WIP)</span>
            </div>
            <div className="glass-panel p-6 rounded-2xl flex flex-col items-center justify-center h-32 border-dashed border-white/20">
              <span className="text-white/40">Task Manager (WIP)</span>
            </div>
            <div className="glass-panel p-6 rounded-2xl flex flex-col items-center justify-center h-32 border-dashed border-white/20">
              <span className="text-white/40">File Manager (WIP)</span>
            </div>
            <div className="glass-panel p-6 rounded-2xl flex flex-col items-center justify-center h-32 border-dashed border-white/20">
              <span className="text-white/40">Power Controls (WIP)</span>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
