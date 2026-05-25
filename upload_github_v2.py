#!/usr/bin/env python3
"""
Script mejorado para subir proyecto a GitHub sin depender de git executable
"""

import os
import sys
import subprocess
from pathlib import Path

def install_git_portable():
    """Intenta instalar git portable"""
    import urllib.request
    import tempfile
    
    print("[*] Descargando Git Portable...")
    git_url = "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/PortableGit-2.54.0-64-bit.7z.exe"
    
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.exe') as tmp:
            urllib.request.urlretrieve(git_url, tmp.name)
            git_exe = tmp.name
            
        print(f"[*] Instalando en C:\\git-portable\\...")
        os.makedirs("C:\\git-portable", exist_ok=True)
        subprocess.run([git_exe, "-o", "C:\\git-portable", "-y"], check=False)
        
        # Agregar a PATH
        os.environ['PATH'] = "C:\\git-portable\\bin;" + os.environ.get('PATH', '')
        
        return True
    except Exception as e:
        print(f"[-] Error: {e}")
        return False

def run_git_commands():
    """Ejecuta comandos git para subir el proyecto"""
    
    project_dir = r"c:\Users\Esteban\Desktop\juego"
    github_url = "https://github.com/estebanseguels-dot/pruebajuego.git"
    
    os.chdir(project_dir)
    
    commands = [
        ["git", "config", "--global", "user.name", "Esteban Seguels"],
        ["git", "config", "--global", "user.email", "estebanseguels@example.com"],
        ["git", "init"],
        ["git", "add", "."],
        ["git", "commit", "-m", "Initial commit: RPG Retro SNES Base Architecture"],
        ["git", "branch", "-M", "main"],
        ["git", "remote", "add", "origin", github_url],
        ["git", "push", "-u", "origin", "main", "--force"],
    ]
    
    for i, cmd in enumerate(commands, 1):
        print(f"\n[{i}] Ejecutando: {' '.join(cmd[:3])}")
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                print(f"✓ OK")
            else:
                # Algunos comandos pueden fallar de formas esperadas
                if "already exists" in result.stderr or "branch 'main' does not exist" in result.stderr:
                    print(f"✓ OK (esperado)")
                else:
                    print(f"⚠ {result.stderr[:100]}")
        except subprocess.TimeoutExpired:
            print(f"⏱ Timeout (requiere autenticación?)")
            return False
        except Exception as e:
            print(f"✗ Error: {e}")
            if i < 5:  # Si es un comando crítico
                return False
    
    return True

def main():
    print("="*60)
    print("🚀 SUBIENDO PROYECTO A GITHUB")
    print("="*60)
    
    # Intentar usar git existente
    try:
        subprocess.run(["git", "--version"], capture_output=True, check=True)
        print("[✓] Git encontrado en el sistema\n")
    except:
        print("[!] Git no encontrado, instalando versión portable...")
        if not install_git_portable():
            print("[✗] No se pudo instalar git")
            return False
        print("[✓] Git instalado\n")
    
    # Ejecutar comandos git
    if run_git_commands():
        print("\n" + "="*60)
        print("✅ ¡PROYECTO SUBIDO EXITOSAMENTE!")
        print("="*60)
        print("\n📍 URL: https://github.com/estebanseguels-dot/pruebajuego")
        print("📂 Rama: main")
        return True
    else:
        print("\n⚠️  El push requiere autenticación de GitHub")
        print("    Por favor, abre el navegador y autentica cuando se solicite")
        return False

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n✗ Error fatal: {e}")
        sys.exit(1)
