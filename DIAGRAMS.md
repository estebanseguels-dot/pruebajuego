## 📊 Diagramas de Arquitectura

### 1. ÁRBOL DE ESCENAS

```
Root (get_tree().root)
│
├── GameManager ★ (AutoLoad/Singleton)
│   ├── Signal: player_entered_battle
│   ├── Signal: battle_finished
│   ├── Data: player_data (Global)
│   └── Data: current_encounter
│
├── SceneLoader ★ (AutoLoad/Singleton)
│   ├── CanvasLayer (transiciones)
│   └── ColorRect (fade effect)
│
└── [Scene Actual] (Se carga/descarga dinámicamente)
	│
	├─ WorldMap (cuando estamos explorando)
	│   ├── Player (CharacterBody2D)
	│   │   ├── AnimatedSprite2D
	│   │   ├── CollisionShape2D
	│   │   └── InteractionArea (Area2D)
	│   │       └── CollisionShape2D
	│   │
	│   ├── Camera2D (sigue al jugador)
	│   │
	│   ├── TileMap (mapa de tiles)
	│   │
	│   ├── AudioStreamPlayer (música)
	│   │
	│   └── Enemy_1..N (CharacterBody2D)
	│       ├── AnimatedSprite2D
	│       ├── CollisionShape2D
	│       └── DetectionArea (Area2D)
	│           └── CollisionShape2D
	│
	└─ Battle (cuando estamos en combate)
		├── BattleBackground (ColorRect)
		│
		├── Camera2D (enfoque en batalla)
		│
		├── AudioStreamPlayer (música batalla)
		│
		└── BattleUI (Control)
			├── PlayerHUD (VBoxContainer)
			│   ├── PlayerNameLabel (Label)
			│   └── PlayerHPBar (ProgressBar)
			│
			├── ActionMenu (VBoxContainer)
			│   ├── Button_Attack
			│   ├── Button_Defend
			│   ├── Button_Item
			│   └── Button_Escape
			│
			└── EnemyInfoContainer (VBoxContainer)
				└── [Dinámicamente lleno con enemigos]
```

---

### 2. FLUJO DE SISTEMAS

```
┌──────────────────────────────────────────────────────────────┐
│                       ENTRADA DEL JUEGO                       │
│                      (main.tscn/main.gd)                      │
└──────────────────────────────────────────┬────────────────────┘
										   │
					┌──────────────────────v────────────────────┐
					│  AutoLoads Cargados Automáticamente        │
					│  - GameManager                             │
					│  - SceneLoader                             │
					└──────────────────────┬────────────────────┘
										   │
					┌──────────────────────v────────────────────┐
					│  Main._ready()                             │
					│  → SceneLoader.load_scene(WorldMap)       │
					└──────────────────────┬────────────────────┘
										   │
		   ┌───────────────────────────────v────────────────────────┐
		   │                    EXPLORACIÓN (WorldMap)               │
		   │                                                          │
		   │  ┌─────────────────┐        ┌─────────────────┐         │
		   │  │   Jugador       │        │    Enemigos     │         │
		   │  │   (PlayerCtrl)  │        │   (EnemyCtrl)   │         │
		   │  │                 │        │                 │         │
		   │  │ - Movimiento    │        │ - Patrulla      │         │
		   │  │ - Animaciones   │        │ - Detección     │         │
		   │  │ - Colisiones    │        │ - Persecución   │         │
		   │  │ - Input         │        │ - Persecución   │         │
		   │  └────────┬────────┘        └────────┬────────┘         │
		   │           │                          │                  │
		   │           └──────────────┬───────────┘                  │
		   │                          │                              │
		   │              ┌───────────v───────────┐                  │
		   │              │  Detección Colisión   │                  │
		   │              │  (PlayerCtrl.enter)   │                  │
		   │              └───────────┬───────────┘                  │
		   │                          │                              │
		   │          ┌───────────────v──────────────┐               │
		   │          │  EnemyCtrl.trigger_encounter()               │
		   │          │  → GameManager.start_encounter()             │
		   │          └───────────────┬──────────────┘               │
		   └──────────────────────────┼──────────────────────────────┘
									  │
					┌─────────────────v──────────────┐
					│   TRANSICIÓN (SceneLoader)     │
					│                                 │
					│ 1. Fade out (0.5s)             │
					│ 2. Guardar estado jugador      │
					│ 3. Descargar WorldMap          │
					│ 4. Cargar BattleScene          │
					│ 5. Fade in (0.5s)              │
					└─────────────────┬──────────────┘
									  │
		   ┌───────────────────────────v────────────────────────┐
		   │               COMBATE (BattleScene)                │
		   │                                                     │
		   │  ┌──────────────────────────────────────────┐      │
		   │  │  BattleController._ready()              │      │
		   │  │  - Inicializar BattleCharacter(player)  │      │
		   │  │  - Inicializar BattleCharacter(enemy)   │      │
		   │  │  - Calcular orden de turnos            │      │
		   │  │  - Mostrar BattleUI                    │      │
		   │  └──────────────────┬───────────────────────┘      │
		   │                     │                              │
		   │     ┌───────────────v────────────────┐             │
		   │     │  Turno del Jugador             │             │
		   │     │  - Selecciona acción           │             │
		   │     │ - execute_player_action()      │             │
		   │     │ - Calcular daño                │             │
		   │     │ - Aplicar daño a enemigo       │             │
		   │     └───────────────┬────────────────┘             │
		   │                     │                              │
		   │     ┌───────────────v────────────────┐             │
		   │     │  Verificar Fin Batalla         │             │
		   │     │  - ¿Enemigo derrotado?         │             │
		   │     │  - ¿Jugador derrotado?         │             │
		   │     │  - ¿Continuar combate?         │             │
		   │     └───────────────┬────────────────┘             │
		   │                     │                              │
		   │     ┌───────────────v────────────────┐             │
		   │     │  Turno de Enemigos             │             │
		   │     │  - IA automática               │             │
		   │     │ - Calcular daño                │             │
		   │     │ - Aplicar daño a jugador       │             │
		   │     └───────────────┬────────────────┘             │
		   │                     │                              │
		   │           (Repetir turnos hasta fin)               │
		   │                     │                              │
		   │     ┌───────────────v────────────────┐             │
		   │     │  Fin de Batalla                │             │
		   │     │  - Calcular recompensas        │             │
		   │     │  - Entregar EXP/Gold           │             │
		   │     │ - Check level-up               │             │
		   │     └───────────────┬────────────────┘             │
		   └─────────────────────┼──────────────────────────────┘
								 │
				 ┌────────────────v──────────────┐
				 │   TRANSICIÓN DE REGRESO       │
				 │   (SceneLoader)               │
				 │                               │
				 │ 1. Fade out (0.5s)            │
				 │ 2. Descargar BattleScene      │
				 │ 3. Cargar WorldMap            │
				 │ 4. Restaurar pos jugador      │
				 │ 5. Restaurar HP jugador       │
				 │ 6. Fade in (0.5s)             │
				 └────────────────┬──────────────┘
								  │
		   ┌──────────────────────v─────────────────────────┐
		   │  EXPLORACIÓN (Continuado con recompensas)      │
		   │  - Jugador continúa aventura                   │
		   │  - Nuevos encuentros posibles                  │
		   │  - Ciclo se repite                             │
		   └───────────────────────────────────────────────┘
```

---

### 3. CAPAS DE ARQUITECTURA

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                         │
│  (Visualización e Interacción del Usuario)                   │
├──────────────────────────────────────────────────────────────┤
│  • PlayerController (input + animación)                       │
│  • EnemyController (animación + patrulla visual)             │
│  • BattleUI (menú visual + barras de HP)                     │
│  • Transiciones visuales (fade, slide)                       │
└──────────────────────────────────────────────────────────────┘
							 │
							 ↓
┌──────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  (Lógica Principal del Juego)                               │
├──────────────────────────────────────────────────────────────┤
│  • WorldMapController (gestiona exploración)                │
│  • BattleController (gestiona combate)                      │
│  • GameManager (orquesta flujo global)                      │
│  • SceneLoader (transiciones entre escenas)                 │
└──────────────────────────────────────────────────────────────┘
							 │
							 ↓
┌──────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                              │
│  (Lógica de Negocio del RPG)                               │
├──────────────────────────────────────────────────────────────┤
│  • BattleCharacter (stats + cálculos de daño)               │
│  • Encounter logic (organizador de encuentros)              │
│  • Level-up system (experiencia y progresión)              │
│  • Equipment system (bonificaciones estadísticas)           │
└──────────────────────────────────────────────────────────────┘
							 │
							 ↓
┌──────────────────────────────────────────────────────────────┐
│                    PERSISTENCE LAYER                         │
│  (Almacenamiento y Recuperación)                            │
├──────────────────────────────────────────────────────────────┤
│  • Player Data (HP, EXP, Level, Gold, Posición)            │
│  • Game State (escena actual, encuentros)                   │
│  • Save/Load (persistencia a archivos)                      │
└──────────────────────────────────────────────────────────────┘
```

---

### 4. CICLO DE VIDA DE UN ENCUENTRO

```
PASO 1: DETECCIÓN
┌─────────────────────────────┐
│ Player toca Enemy (colisión)│
│ InteractionArea.area_entered│
└────────────┬────────────────┘
			 │
PASO 2: TRIGGER
┌────────────v────────────────┐
│ EnemyController._on_touched()
│ trigger_encounter()          │
└────────────┬────────────────┘
			 │
PASO 3: SOLICITUD
┌────────────v────────────────────────────────┐
│ GameManager.start_encounter([enemies], diff) │
└────────────┬────────────────────────────────┘
			 │
PASO 4: ESTADO
┌────────────v────────────────────────────┐
│ is_transitioning = true                 │
│ Guardar: player_data["position"]        │
│ Guardar: current_encounter = {...}      │
│ Emitir: scene_transition_started        │
└────────────┬─────────────────────────────┘
			 │
PASO 5: ANIMACIÓN ENTRADA
┌────────────v────────────────┐
│ SceneLoader._fade_in()       │
│ Pantalla a negro (0.5s)     │
└────────────┬────────────────┘
			 │
PASO 6: CAMBIO ESCENA
┌────────────v────────────────────────────┐
│ SceneLoader._execute_transition_in()    │
│ Descargar: WorldMap                     │
│ Cargar: BattleScene                     │
│ Instanciar: BattleController            │
└────────────┬─────────────────────────────┘
			 │
PASO 7: INICIALIZACIÓN BATALLA
┌────────────v────────────────────────────┐
│ BattleController._ready()               │
│ Inicializar player (BattleCharacter)    │
│ Inicializar enemies (Array[BattleChar]) │
│ Calcular: turn_order                    │
│ Crear: BattleUI                         │
└────────────┬─────────────────────────────┘
			 │
PASO 8: ANIMACIÓN SALIDA
┌────────────v─────────────────┐
│ SceneLoader._fade_out()       │
│ Pantalla de negro (0.5s)     │
└────────────┬──────────────────┘
			 │
PASO 9: LISTO
┌────────────v────────────────────────┐
│ is_transitioning = false            │
│ Emitir: scene_transition_finished   │
│ Emitir: player_entered_battle       │
│ → COMBATE LISTO                     │
└────────────┬───────────────────────┘
			 │
			 ↓
		[COMBATE TURNADO]
		(Turnos del jugador y enemigos)
			 │
			 ↓
		[FIN DE BATALLA]
		→ Victory / Defeat
			 │
		GameManager.end_encounter(victory, exp, loot)
			 │
			 ↓
		(Proceso similar pero inverso - vuelta a WorldMap)
```

---

### 5. COMUNICACIÓN ENTRE SISTEMAS

```
┌─────────────────┐
│ Player Input    │
└────────┬────────┘
		 │
		 v
┌─────────────────────────────────────────────┐
│  PlayerController._process()                │
│  - Procesar input (flechas)                 │
│  - Calcular dirección                       │
│  - Mover CharacterBody2D                    │
│  - Actualizar animaciones                   │
└────────┬────────────────────────────────────┘
		 │
		 ├─→ Colisión detectada
		 │     │
		 │     v
		 │   ┌──────────────────────────────┐
		 │   │ InteractionArea.area_entered │
		 │   └────────┬─────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ EnemyController.trigger_encounter│
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ GameManager.start_encounter()    │
		 │   │ ⚠️ PUNTO DE TRANSICIÓN           │
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ SceneLoader.load_scene(          │
		 │   │   "battle_scene.tscn")           │
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ BattleController._ready()        │
		 │   │ → Crea BattleUI                  │
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ BattleUI._on_action_pressed()    │
		 │   │ ← Espera input del jugador       │
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ BattleController.execute_player_ │
		 │   │   action(action, target)         │
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ BattleCharacter.calculate_damage(│
		 │   │   target)                        │
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ BattleCharacter.take_damage()    │
		 │   │ → Actualiza health               │
		 │   └────────┬──────────────────────────┘
		 │            │
		 │            v
		 │   ┌──────────────────────────────────┐
		 │   │ BattleUI.show_damage()           │
		 │   │ → Anima barra de HP              │
		 │   └────────┬──────────────────────────┘
		 │            │
		 └────────────┴──────→ [Loop continúa hasta fin]
							   │
							   v
					┌──────────────────────────────┐
					│ BattleController._check_     │
					│   battle_end()               │
					│ → ¿Enemigo/Jugador muerto?  │
					└────────┬─────────────────────┘
							 │
							 v
					┌──────────────────────────────┐
					│ GameManager.end_encounter()  │
					│ ⚠️ PUNTO DE RETORNO          │
					│ → Actualizar player_data    │
					└────────┬─────────────────────┘
							 │
							 v
					┌──────────────────────────────┐
					│ SceneLoader.load_scene(      │
					│   "world_map.tscn")          │
					└────────┬─────────────────────┘
							 │
							 v
					┌──────────────────────────────┐
					│ WorldMapController._ready()  │
					│ → Restaurar posición jugador │
					│ → Restaurar HP               │
					└────────┬─────────────────────┘
							 │
							 v
					[VUELTA A EXPLORACIÓN]
					Ciclo se repite
```

---

### 6. TABLA DE COLISIONES

```
CAPA 1 (Player):
┌─────────────────────────────────────┐
│ collision_layer  = 1  (activa capa) │
│ collision_mask   = 2  (detecta cap) │
│ Detecta: Enemigos                   │
└─────────────────────────────────────┘

CAPA 2 (Enemy):
┌─────────────────────────────────────┐
│ collision_layer  = 2  (activa capa) │
│ collision_mask   = 1  (detecta cap) │
│ Detecta: Jugador                    │
└─────────────────────────────────────┘

CAPA 3 (Tilemap - opcional):
┌─────────────────────────────────────┐
│ collision_layer  = 4  (activa capa) │
│ collision_mask   = 3  (detecta cap) │
│ Detecta: Player + Enemy              │
└─────────────────────────────────────┘

INTERACCIÓN:
Player(1) vs Enemy(2) = ✅ Detecta
Enemy(2) vs Player(1) = ✅ Detecta
Enemy vs Enemy        = ❌ No detecta
```

---

**Estos diagramas te ayudarán a entender cómo todo encaja juntoDescarga la arquitectura completa y comienza a expandir! 🎮**
