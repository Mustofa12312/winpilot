import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/client';
import { Monitor, ArrowRight, Activity } from 'lucide-react';

export default function Login() {
  const [ip, setIp] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const saved = localStorage.getItem('winpilot_ip');
    if (saved) setIp(saved);
  }, []);

  const handleLogin = async (e) => {
    e.preventDefault();
    if (!ip) return;

    setLoading(true);
    setError('');

    const success = await api.login(ip);
    if (success) {
      navigate('/dashboard');
    } else {
      setError('Koneksi gagal. Pastikan Agent aktif dan IP benar.');
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 relative overflow-hidden">
      {/* Background Ornaments */}
      <div className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] bg-[var(--color-win-primary)]/20 blur-[120px] rounded-full pointer-events-none" />
      <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-[var(--color-win-success)]/10 blur-[100px] rounded-full pointer-events-none" />
      
      <div className="w-full max-w-md">
        <div className="text-center mb-10 relative z-10">
          <div className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-[#2D8CFF] to-[#1A75E6] shadow-[0_0_40px_rgba(45,140,255,0.4)] flex items-center justify-center">
            <Monitor className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-4xl font-extrabold tracking-tight mb-2">WinPilot</h1>
          <p className="text-white/60">Your Personal Windows Server</p>
        </div>

        <form onSubmit={handleLogin} className="glass-panel p-8 rounded-3xl shadow-2xl relative z-10">
          <h2 className="text-xl font-bold mb-2">Hubungkan ke PC</h2>
          <p className="text-sm text-white/50 mb-6">Masukkan IP Address komputer Anda</p>

          <div className="space-y-5">
            <div>
              <div className="relative">
                <Monitor className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
                <input
                  type="text"
                  value={ip}
                  onChange={(e) => setIp(e.target.value)}
                  placeholder="192.168.1.100"
                  className="w-full bg-white/5 border border-white/10 rounded-xl py-3 pl-12 pr-4 text-white placeholder:text-white/30 focus:outline-none focus:border-[var(--color-win-primary)] focus:ring-1 focus:ring-[var(--color-win-primary)] transition-all"
                  required
                />
              </div>
            </div>

            {error && (
              <div className="p-3 bg-[var(--color-win-danger)]/20 border border-[var(--color-win-danger)]/50 rounded-lg text-[var(--color-win-danger)] text-sm">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[var(--color-win-primary)] hover:bg-[var(--color-win-primary-hover)] text-white rounded-xl py-3.5 font-semibold transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? (
                <>
                  <Activity className="w-5 h-5 animate-spin" />
                  Menyambungkan...
                </>
              ) : (
                <>
                  Connect <ArrowRight className="w-5 h-5" />
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
