import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { LogOut, MonitorSmartphone, Power, RefreshCw, Cpu, HardDrive, Activity, Wifi, XCircle, PowerOff, ShieldAlert, Moon } from 'lucide-react';
import { api } from '../api/client';

export default function Dashboard() {
  const navigate = useNavigate();
  const ip = localStorage.getItem('winpilot_ip') || 'Unknown';

  const [monitor, setMonitor] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [loadingTasks, setLoadingTasks] = useState(false);

  // Polling for Monitor Data
  useEffect(() => {
    const fetchMonitor = async () => {
      const data = await api.getMonitor();
      if (data) setMonitor(data);
    };
    fetchMonitor();
    const interval = setInterval(fetchMonitor, 3000);
    return () => clearInterval(interval);
  }, []);

  // Fetch Tasks
  const fetchTasks = async () => {
    setLoadingTasks(true);
    const data = await api.getTasks();
    // Sort tasks by CPU usage (descending)
    data.sort((a, b) => b.cpu_percent - a.cpu_percent);
    setTasks(data.slice(0, 15)); // Top 15
    setLoadingTasks(false);
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('winpilot_token');
    navigate('/login');
  };

  const handlePower = async (action) => {
    if (window.confirm(`Are you sure you want to ${action} the remote PC?`)) {
      await api.sendPowerCommand(action);
      alert(`${action} command sent.`);
    }
  };

  const handleKill = async (pid, name) => {
    if (window.confirm(`Kill process ${name} (PID: ${pid})?`)) {
      await api.killTask(pid);
      fetchTasks();
    }
  };

  return (
    <div className="min-h-screen bg-[var(--color-win-bg)] text-white flex flex-col overflow-hidden">
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
      <main className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-7xl mx-auto space-y-8">
          
          {/* Top Row: Monitor & Power */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            
            {/* System Monitor */}
            <div className="lg:col-span-2 glass-panel p-6 rounded-2xl">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold flex items-center gap-2"><Activity className="w-5 h-5 text-blue-400" /> System Monitor</h2>
                {monitor && <span className="text-xs text-white/40 font-mono">Uptime: {(monitor.uptime / 3600).toFixed(1)}h</span>}
              </div>
              
              {!monitor ? (
                <div className="flex justify-center items-center h-32"><RefreshCw className="w-6 h-6 animate-spin text-white/30" /></div>
              ) : (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {/* CPU */}
                  <div className="bg-white/5 rounded-xl p-4 flex flex-col items-center justify-center border border-white/5 relative overflow-hidden">
                    <div className="absolute top-2 left-2"><Cpu className="w-4 h-4 text-white/30" /></div>
                    <div className="text-3xl font-bold text-blue-400 mb-1">{monitor.cpu.usage_percent.toFixed(0)}%</div>
                    <div className="text-xs text-white/50">{monitor.cpu.model_name || 'CPU Usage'}</div>
                    <div className="w-full h-1 bg-white/10 rounded-full mt-3 overflow-hidden">
                      <div className="h-full bg-blue-500" style={{ width: `${monitor.cpu.usage_percent}%` }}></div>
                    </div>
                  </div>
                  {/* RAM */}
                  <div className="bg-white/5 rounded-xl p-4 flex flex-col items-center justify-center border border-white/5 relative overflow-hidden">
                    <div className="absolute top-2 left-2"><Activity className="w-4 h-4 text-white/30" /></div>
                    <div className="text-3xl font-bold text-green-400 mb-1">{monitor.ram.usage_percent.toFixed(0)}%</div>
                    <div className="text-xs text-white/50">RAM Usage</div>
                    <div className="w-full h-1 bg-white/10 rounded-full mt-3 overflow-hidden">
                      <div className="h-full bg-green-500" style={{ width: `${monitor.ram.usage_percent}%` }}></div>
                    </div>
                  </div>
                  {/* Disk */}
                  <div className="bg-white/5 rounded-xl p-4 flex flex-col items-center justify-center border border-white/5 relative overflow-hidden">
                    <div className="absolute top-2 left-2"><HardDrive className="w-4 h-4 text-white/30" /></div>
                    <div className="text-3xl font-bold text-orange-400 mb-1">{monitor.disk.usage_percent.toFixed(0)}%</div>
                    <div className="text-xs text-white/50">Disk Usage</div>
                    <div className="w-full h-1 bg-white/10 rounded-full mt-3 overflow-hidden">
                      <div className="h-full bg-orange-500" style={{ width: `${monitor.disk.usage_percent}%` }}></div>
                    </div>
                  </div>
                  {/* Network */}
                  <div className="bg-white/5 rounded-xl p-4 flex flex-col items-center justify-center border border-white/5 relative overflow-hidden">
                    <div className="absolute top-2 left-2"><Wifi className="w-4 h-4 text-white/30" /></div>
                    <div className="text-lg font-bold text-purple-400 mb-1 truncate w-full text-center">
                      {(monitor.network.recv_bytes_per_sec / 1024 / 1024).toFixed(1)} MB/s
                    </div>
                    <div className="text-xs text-white/50">Download Speed</div>
                    <div className="mt-3 text-xs text-white/30 truncate w-full text-center">
                      Up: {(monitor.network.sent_bytes_per_sec / 1024 / 1024).toFixed(1)} MB/s
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Power Controls */}
            <div className="glass-panel p-6 rounded-2xl flex flex-col">
              <h2 className="text-xl font-bold mb-6 flex items-center gap-2"><Power className="w-5 h-5 text-red-400" /> Power Controls</h2>
              <div className="grid grid-cols-2 gap-4 flex-1">
                <button onClick={() => handlePower('shutdown')} className="bg-red-500/10 hover:bg-red-500/20 border border-red-500/30 text-red-400 rounded-xl flex flex-col items-center justify-center p-4 transition-all gap-2">
                  <PowerOff className="w-6 h-6" />
                  <span className="text-sm font-semibold">Shutdown</span>
                </button>
                <button onClick={() => handlePower('restart')} className="bg-orange-500/10 hover:bg-orange-500/20 border border-orange-500/30 text-orange-400 rounded-xl flex flex-col items-center justify-center p-4 transition-all gap-2">
                  <RefreshCw className="w-6 h-6" />
                  <span className="text-sm font-semibold">Restart</span>
                </button>
                <button onClick={() => handlePower('sleep')} className="bg-blue-500/10 hover:bg-blue-500/20 border border-blue-500/30 text-blue-400 rounded-xl flex flex-col items-center justify-center p-4 transition-all gap-2">
                  <Moon className="w-6 h-6" />
                  <span className="text-sm font-semibold">Sleep</span>
                </button>
                <button onClick={() => handlePower('lock')} className="bg-gray-500/10 hover:bg-gray-500/20 border border-gray-500/30 text-gray-400 rounded-xl flex flex-col items-center justify-center p-4 transition-all gap-2">
                  <ShieldAlert className="w-6 h-6" />
                  <span className="text-sm font-semibold">Lock</span>
                </button>
              </div>
            </div>

          </div>

          {/* Bottom Row: Task Manager */}
          <div className="glass-panel p-6 rounded-2xl">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-bold flex items-center gap-2"><Activity className="w-5 h-5 text-green-400" /> Top Processes</h2>
              <button onClick={fetchTasks} disabled={loadingTasks} className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-colors disabled:opacity-50">
                <RefreshCw className={`w-4 h-4 ${loadingTasks ? 'animate-spin' : ''}`} />
              </button>
            </div>
            
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="border-b border-white/10 text-xs uppercase text-white/40">
                    <th className="pb-3 pl-2 font-medium">Process Name</th>
                    <th className="pb-3 font-medium">PID</th>
                    <th className="pb-3 font-medium text-right">CPU</th>
                    <th className="pb-3 font-medium text-right">RAM</th>
                    <th className="pb-3 pr-2 font-medium text-right">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {tasks.length === 0 ? (
                    <tr>
                      <td colSpan="5" className="py-8 text-center text-white/30">No tasks found or loading...</td>
                    </tr>
                  ) : (
                    tasks.map((task) => (
                      <tr key={task.pid} className="border-b border-white/5 hover:bg-white/5 transition-colors">
                        <td className="py-3 pl-2 flex items-center gap-3">
                          <div className="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-xs font-bold text-white/70">
                            {task.name.charAt(0).toUpperCase()}
                          </div>
                          <span className="font-medium truncate max-w-[150px] md:max-w-xs">{task.name}</span>
                        </td>
                        <td className="py-3 text-white/50 text-sm">{task.pid}</td>
                        <td className="py-3 text-right">
                          <span className={`px-2 py-1 rounded text-xs ${task.cpu_percent > 10 ? 'bg-orange-500/20 text-orange-400' : 'text-white/70'}`}>
                            {task.cpu_percent.toFixed(1)}%
                          </span>
                        </td>
                        <td className="py-3 text-right text-white/70 text-sm">
                          {(task.memory_usage / 1024 / 1024).toFixed(0)} MB
                        </td>
                        <td className="py-3 pr-2 text-right">
                          <button
                            onClick={() => handleKill(task.pid, task.name)}
                            className="p-2 rounded-lg text-red-400 hover:bg-red-500/20 transition-colors"
                            title="Kill Process"
                          >
                            <XCircle className="w-4 h-4" />
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </main>
    </div>
  );
}
