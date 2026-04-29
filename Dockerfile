FROM debian

# Memasukkan Token dan Region langsung ke dalam build
ENV NGROK_TOKEN=3D1q1q023EBNQNMO6kxoI9VTmOc_NsHTY6Zts8nn6yy88Bh6
ENV REGION=ap
ENV DEBIAN_FRONTEND=noninteractive

# 1. Update dan install paket dasar
RUN apt update && apt upgrade -y && apt install -y \
    openssh-server wget unzip vim curl python3 \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup Ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O /ngrok-stable-linux-amd64.zip \
    && unzip /ngrok-stable-linux-amd64.zip -d / \
    && chmod +x /ngrok \
    && rm /ngrok-stable-linux-amd64.zip

# 3. Konfigurasi SSH dan Script Otomatis
# Menggunakan mkdir -p agar tidak error jika direktori sudah ada
RUN mkdir -p /run/sshd \
    && echo "/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 22 &" >> /openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print('ssh info:\\n', 'ssh', 'root@'+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '), '\\nROOT Password:craxid')\" || echo \"\nError: Periksa koneksi atau Ngrok Token Anda\n\"" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'root:craxid' | chpasswd \
    && chmod 755 /openssh.sh

# 4. Ekspose Port Umum
EXPOSE 22 80 443 3306 4040 8080 9000

# 5. Jalankan Service
CMD ["/bin/bash", "/openssh.sh"]
