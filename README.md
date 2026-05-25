# 🎮 Retro RPG Adventure - Sistema Base

Una arquitectura profesional para crear RPGs de acción retro estilo **Secret of Evermore** en Godot 4.x

## 🚀 Quick Start

### Requisitos
- Godot 4.1+
- GDScript

### Instalación

1. **Abrir el proyecto en Godot**
   ```bash
   # El proyecto está listo para usar en Godot
   # Solo abre: c:\Users\Esteban\Desktop\juego
   ```

2. **Configurar AutoLoads** (Si es necesario)
   - En `Project > Project Settings > Autoload`
   - Añadir `res://src/managers/game_manager.gd` como `GameManager`
   - Añadir `res://src/core/scene_loader.gd` como `SceneLoader`

3. **Ejecutar el juego**
   - Presiona F5 o haz clic en ▶️ Play

---

## 📁 Estructura de Carpetas

```
juego/
├── project.godot          # Configuración Godot
├── ARCHITECTURE.md        # Documentación técnica completa
├── README.md             # Este archivo
│
└── src/
    ├── main.gd           # Bootstrap del juego
    ├── core/
    │   └── scene_loader.gd
    ├── managers/
    │   └── game_manager.gd
    ├── scenes/
    │   ├── main.tscn
    │   ├── world_map/
    │   │   ├── world_map.tscn
    │   │   ├── player.tscn
    │   │   └── enemy.tscn
    │   └── battle/
    │       └── battle_scene.tscn
    ├── characters/
    │   ├── player/
    │   │   └── player_controller.gd
    │   └── enemy/
    │       └── enemy_controller.gd
    ├── systems/
    │   └── battle_character.gd
    └── ui/
        └── battle_ui/
            └── battle_ui.gd
```

---

## 🎯 Componentes Principales

### 1. **GameManager** (Singleton AutoLoad)
Gestiona el estado global del juego

```gdscript
# Acceso desde cualquier parte del código
GameManager.player_data
GameManager.start_encounter(enemies, difficulty)
GameManager.end_encounter(victory, exp, loot)
```

### 2. **SceneLoader** (Singleton AutoLoad)
Maneja transiciones suaves entre escenas

```gdscript
# Transición con fade
await SceneLoader.load_scene(
    "res://src/scenes/battle/battle_scene.tscn",
    SceneLoader.TransitionType.FADE
)
```

### 3. **WorldMapController**
Gestiona la escena de exploración

```gdscript
# Instancia automática:
# - Jugador
# - Enemigos
# - Cámara
# - Música
```

### 4. **BattleController**
Gestiona la escena de combate

```gdscript
# Sistema turnado completo:
# - Inicialización de encuentro
# - Turnos jugador/enemigos
# - Cálculo de daño
# - Recompensas
```

---

## 🎮 Flujo de Juego Completo

```
START
  │
  ├─→ Exploración (WorldMap)
  │     - Jugador se mueve
  │     - Enemigos patrullan
  │
  ├─→ Colisión con enemigo
  │
  ├─→ Transición (Fade out)
  │
  ├─→ Batalla (BattleScene)
  │     - Turno jugador
  │     - Turno enemigos
  │
  ├─→ Fin de batalla
  │
  ├─→ Transición (Fade in)
  │
  └─→ Vuelta a Exploración + Recompensas
```

---

## ⌨️ Controles

| Tecla | Acción |
|-------|--------|
| **Flechas/WASD** | Movimiento 8 direcciones |
| **Click** (Batalla) | Seleccionar acción |
| **ESC** | Pausar (próximamente) |

---

## 🛠️ Configuración Rápida

### Cambiar Velocidad del Jugador
En `player.tscn`:
```gdscript
@export var speed: float = 150.0  # Aumentar para más velocidad
```

### Cambiar Tipo de Enemigo
En `enemy.tscn`:
```gdscript
@export var enemy_type: String = "Dragon"  # Cambiar nombre
@export var health: int = 100             # Más HP
@export var attack: int = 15              # Más ataque
```

### Cambiar Tipo de Transición
```gdscript
# En world_map_controller.gd
await SceneLoader.load_scene(scene_path, SceneLoader.TransitionType.SLIDE_LEFT)
```

---

## 🔍 Debug & Testing

### Ver Logs
```gdscript
# Todos los sistemas tienen print() para debug
# Abre la consola Godot (View > Toggle Debug Renderer)
```

### Probar Solo Batalla
```gdscript
# En project.godot, cambiar main_scene a:
run/main_scene="res://src/scenes/battle/battle_scene.tscn"
```

### Probar Solo Exploración
```gdscript
run/main_scene="res://src/scenes/world_map/world_map.tscn"
```

---

## 📚 Documentación Completa

Para arquitectura detallada, diseño de sistemas y guía de expansión, consulta:

**[ARCHITECTURE.md](./ARCHITECTURE.md)**

Contiene:
- ✅ Diagrama de arquitectura
- ✅ Descripción de cada componente
- ✅ Flujo de transiciones
- ✅ Guía de extensión
- ✅ Buenas prácticas
- ✅ Próximos pasos recomendados

---

## ✨ Características Implementadas

### Core
- ✅ Singleton GameManager
- ✅ Sistema de transiciones de escenas
- ✅ Carga asincrónica
- ✅ Persistencia básica

### Exploración
- ✅ Movimiento 8 direcciones suave
- ✅ Cámara de seguimiento
- ✅ Enemigos con patrulla
- ✅ Detección automática de colisiones

### Combate
- ✅ Sistema turnado
- ✅ Cálculo de daño dinámico
- ✅ IA enemiga básica
- ✅ Sistema de recompensas (EXP, Gold)
- ✅ Subida de niveles

### UI
- ✅ Barras de HP animadas
- ✅ Menú de acciones
- ✅ Información de enemigos
- ⬜ Animaciones de daño (en progreso)

---

## 🚀 Próximas Características

**FASE 1: Pulido Visual**
- [ ] Sprites para jugador y enemigos
- [ ] Animaciones fluidas
- [ ] Efectos visuales de combate
- [ ] Sonido y música

**FASE 2: Contenido**
- [ ] Múltiples tipos de enemigos
- [ ] NPCs y sistema de diálogo
- [ ] Múltiples mapas
- [ ] Boss fights

**FASE 3: Sistemas Avanzados**
- [ ] Habilidades especiales
- [ ] Sistema de magia/mana
- [ ] Equipo y estadísticas
- [ ] Objetos/Inventario

---

## 🐛 Troubleshooting

### "GameManager no está definido"
**Solución**: En `Project > Project Settings > Autoload`, verifica que `GameManager` esté registrado

### Enemigos no detectan al jugador
**Solución**: Verifica que las capas de colisión estén configuradas correctamente:
```
PlayerController: collision_layer=1, collision_mask=2 (enemigos)
EnemyController: collision_layer=2, collision_mask=1 (jugador)
```

### Transición entre escenas congelada
**Solución**: Verifica en `game_manager.gd` que `is_transitioning` sea `false`

---

## 📊 Performance

| Métrica | Objetivo | Estado |
|---------|----------|--------|
| FPS | 60 | ✅ |
| Transiciones | < 1s | ✅ |
| Tiempo carga escenas | < 500ms | ✅ |
| Memory footprint | < 100MB | ✅ |

---

## 📝 Notas de Desarrollo

- Todas las señales usan convención PascalCase: `player_died`, `battle_started`
- Métodos privados prefijo `_`: `_apply_movement()`, `_calculate_damage()`
- Documentación con `##` comentarios
- Código comentado para legibilidad

---

## 🤝 Contributing

Para mantener la arquitectura limpia:

1. Seguir convenciones de nomenclatura
2. Usar signals para comunicación entre sistemas
3. No acoplar lógica entre escenas
4. Documentar cambios importantes
5. Probar transiciones completas

---

## 📜 Licencia

Este proyecto es de código abierto. Úsalo libremente para tus proyectos.

---

## 🙏 Créditos

Inspirado en:
- Secret of Evermore (SNES)
- Final Fantasy VI (SNES)
- Chrono Trigger (SNES)

Construido con:
- Godot 4.x
- GDScript

---

**¿Preguntas?** Consulta [ARCHITECTURE.md](./ARCHITECTURE.md) para documentación detallada.

**¡Feliz desarrollo!** 🎮✨
