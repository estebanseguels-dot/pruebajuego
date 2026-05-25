#!/usr/bin/env python3
"""
Script para subir el proyecto a GitHub
"""

import os
import sys
from git import Repo
from pathlib import Path

def upload_to_github():
    project_path = r"c:\Users\Esteban\Desktop\juego"
    github_url = "https://github.com/estebanseguels-dot/pruebajuego.git"
    
    os.chdir(project_path)
    
    print("[1] Inicializando repositorio git local...")
    try:
        repo = Repo.init(project_path)
        print("✓ Repositorio inicializado")
    except Exception as e:
        repo = Repo(project_path)
        print(f"✓ Repositorio ya existe: {e}")
    
    print("\n[2] Agregando archivos...")
    try:
        repo.git.add(A=True)
        print(f"✓ Archivos agregados")
    except Exception as e:
        print(f"✗ Error al agregar archivos: {e}")
        return False
    
    print("\n[3] Configurando usuario git (local)...")
    try:
        repo.config_writer().set_value("user", "name", "Esteban Seguels").release()
        repo.config_writer().set_value("user", "email", "estebanseguels@example.com").release()
        print("✓ Usuario configurado")
    except Exception as e:
        print(f"✗ Error al configurar usuario: {e}")
    
    print("\n[4] Creando commit inicial...")
    try:
        repo.index.commit("Initial commit: RPG Retro SNES Base Architecture")
        print("✓ Commit creado")
    except Exception as e:
        print(f"✗ Error al crear commit: {e}")
        return False
    
    print("\n[5] Agregando remoto origin...")
    try:
        origin = repo.create_remote('origin', github_url)
        print(f"✓ Remoto agregado: {github_url}")
    except Exception as e:
        if "already exists" in str(e):
            print(f"✓ Remoto ya existe")
            origin = repo.remote('origin')
            origin.set_url(github_url)
        else:
            print(f"✗ Error: {e}")
            return False
    
    print("\n[6] Realizando push a main...")
    try:
        # Cambiar a rama main si es necesario
        try:
            repo.heads.main.checkout()
        except:
            repo.create_head('main')
            repo.heads.main.checkout()
        
        # Push a main
        origin.push(repo.heads.main, force=True)
        print("✓ Push completado a main")
    except Exception as e:
        print(f"✗ Error en push: {e}")
        print("\n📝 IMPORTANTE: Debes ingresar tu token/contraseña de GitHub")
        print("   El navegador puede haber abierto para solicitar autenticación.")
        return False
    
    print("\n" + "="*60)
    print("✅ ¡PROYECTO SUBIDO A GITHUB EXITOSAMENTE!")
    print("="*60)
    print(f"\n📍 Repositorio: {github_url}")
    print(f"📂 Rama: main")
    print(f"📊 Commits: {len(list(repo.iter_commits()))}")
    
    return True

if __name__ == "__main__":
    success = upload_to_github()
    sys.exit(0 if success else 1)
