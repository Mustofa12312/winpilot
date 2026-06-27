import axios from 'axios';

class ApiClient {
  constructor() {
    this.client = axios.create({
      baseURL: 'http://127.0.0.1:8080',
      timeout: 5000,
    });

    this.client.interceptors.request.use((config) => {
      const token = localStorage.getItem('winpilot_token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });
  }

  setBaseUrl(ip) {
    const url = `http://${ip}:8080`;
    this.client.defaults.baseURL = url;
    localStorage.setItem('winpilot_ip', ip);
  }

  async login(ip) {
    this.setBaseUrl(ip);
    try {
      // In sprint 1-3, auth wasn't heavily enforced for local discovery, 
      // but we can simulate a health check as a login ping.
      const res = await this.client.get('/health');
      if (res.status === 200) {
        return true;
      }
    } catch (e) {
      console.error(e);
    }
    return false;
  }
}

export const api = new ApiClient();
