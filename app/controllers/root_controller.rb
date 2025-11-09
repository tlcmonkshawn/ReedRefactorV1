class RootController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    render html: <<~HTML.html_safe
      <!DOCTYPE html>
      <html>
      <head>
        <title>R.E.E.D. Bootie Hunter API</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
          }
          .container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          h1 {
            color: #333;
            margin-top: 0;
          }
          .status {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border-radius: 4px;
            display: inline-block;
            margin-bottom: 30px;
          }
          .links {
            margin-top: 30px;
          }
          .links a {
            display: block;
            padding: 15px;
            margin: 10px 0;
            background: #2196F3;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background 0.3s;
          }
          .links a:hover {
            background: #1976D2;
          }
          .api-link {
            background: #9C27B0;
          }
          .api-link:hover {
            background: #7B1FA2;
          }
          code {
            background: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🎯 R.E.E.D. Bootie Hunter</h1>
          <div class="status">✓ API Server Running</div>
          
          <p>Welcome to the R.E.E.D. Bootie Hunter API server.</p>
          
          <div class="links">
            <a href="/admin" class="admin-link">🔐 Admin Dashboard</a>
            <a href="/health" class="api-link">💚 Health Check</a>
            <a href="/api/v1/config" class="api-link">⚙️ API Config</a>
          </div>
          
          <h2>API Endpoints</h2>
          <p>All API endpoints are under <code>/api/v1/</code></p>
          <ul>
            <li><code>POST /api/v1/auth/register</code> - Register new user</li>
            <li><code>POST /api/v1/auth/login</code> - Login</li>
            <li><code>GET /api/v1/booties</code> - List booties</li>
            <li><code>GET /api/v1/locations</code> - List locations</li>
            <li><code>GET /health</code> - Health check</li>
          </ul>
          
          <p style="margin-top: 30px; color: #666; font-size: 14px;">
            Server Time: #{Time.current.strftime('%Y-%m-%d %H:%M:%S UTC')}
          </p>
        </div>
      </body>
      </html>
    HTML
  end
end

