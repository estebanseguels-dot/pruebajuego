## Ejemplos de Extensión del Sistema

### EJEMPLO 1: Agregar un Nuevo Tipo de Enemigo

**Paso 1**: Crear prefab del enemigo

```gdscript
# En res://src/scenes/world_map/enemy_goblin.tscn
# (Duplicar enemy.tscn y modificar)

extends CharacterBody2D
# ... (usar mismo script EnemyController.gd)
```

**Paso 2**: Cambiar propiedades

```gdscript
# En enemy_goblin.tscn
@export var enemy_type: String = "Goblin"
@export var health: int = 35
@export var attack: int = 12
@export var defense: int = 4
@export var level: int = 2
```

**Paso 3**: Agregarlo al spawn

```gdscript
# En world_map_controller.gd
func _spawn_enemies() -> void:
    var enemy_types = [
        load("res://src/scenes/world_map/enemy.tscn"),      # Slime
        load("res://src/scenes/world_map/enemy_goblin.tscn") # Goblin
    ]
    
    for i in range(4):
        var enemy_scene = enemy_types[i % enemy_types.size()]
        var enemy = enemy_scene.instantiate()
        enemy.global_position = spawn_positions[i]
        add_child(enemy)
```

---

### EJEMPLO 2: Sistema de Objetos

**Paso 1**: Extender GameManager

```gdscript
# En game_manager.gd
var inventory: Dictionary = {
    "potion": 3,
    "ether": 1,
    "revive": 0
}

func use_item(item_name: String) -> bool:
    if not item_name in inventory or inventory[item_name] <= 0:
        return false
    
    inventory[item_name] -= 1
    print("[GameManager] Usando: %s" % item_name)
    return true

func add_item(item_name: String, amount: int = 1) -> void:
    if not item_name in inventory:
        inventory[item_name] = 0
    inventory[item_name] += amount
```

**Paso 2**: Usar en batalla

```gdscript
# En battle_controller.gd
func execute_player_action(action: String, target_index: int = 0) -> void:
    match action:
        "item":
            _execute_player_item()

func _execute_player_item() -> void:
    # Mostrar menú de objetos
    var items = GameManager.inventory
    
    # Seleccionar potion (simplificado)
    if GameManager.use_item("potion"):
        player_character.restore_health(50)
        print("[Battle] Usó potion!")
        
        await get_tree().create_timer(0.5).timeout
        _execute_enemy_turns()
```

---

### EJEMPLO 3: Habilidades Especiales

**Paso 1**: Agregar a BattleCharacter

```gdscript
# En battle_character.gd
var skills: Dictionary = {}

func initialize(data: Dictionary, is_player_char: bool = false) -> void:
    # ... código existente ...
    
    # Agregar skills
    skills = {
        "fireball": {
            "damage": 25,
            "cost": 15,  # Costo de mana
            "type": "magic"
        },
        "slash": {
            "damage": 15,
            "cost": 0,
            "type": "physical"
        }
    }

func use_skill(skill_name: String, target: BattleCharacter) -> int:
    if skill_name not in skills:
        return 0
    
    var skill = skills[skill_name]
    var damage = skill["damage"]
    
    # Agregar variación
    damage += randi() % 5 - 2
    
    return max(1, damage)
```

**Paso 2**: Usar en BattleController

```gdscript
# En battle_controller.gd
func execute_player_action(action: String, target_index: int = 0) -> void:
    match action:
        "skill":
            _execute_player_skill("fireball", target_index)

func _execute_player_skill(skill_name: String, target_index: int) -> void:
    var target = enemy_characters[target_index]
    var damage = player_character.use_skill(skill_name, target)
    
    target.take_damage(damage)
    
    if battle_ui:
        battle_ui.show_damage(damage, target_index)
```

---

### EJEMPLO 4: Sistema de Equipo

**Paso 1**: Crear clase de Equipo

```gdscript
# En res://src/systems/equipment.gd
class_name Equipment

var slots: Dictionary = {
    "weapon": null,
    "armor": null,
    "accessory": null
}

var equipment_data: Dictionary = {
    "Iron Sword": {
        "type": "weapon",
        "attack_bonus": 5,
        "defense_bonus": 0,
        "price": 100
    },
    "Leather Armor": {
        "type": "armor",
        "attack_bonus": 0,
        "defense_bonus": 3,
        "price": 50
    }
}

func equip(item_name: String, slot: String) -> bool:
    if item_name not in equipment_data:
        return false
    
    var item = equipment_data[item_name]
    if item["type"] != slot:
        return false
    
    slots[slot] = item_name
    return true

func get_stat_bonuses() -> Dictionary:
    var bonuses = {
        "attack": 0,
        "defense": 0,
        "hp": 0
    }
    
    for slot in slots.values():
        if slot and slot in equipment_data:
            var item = equipment_data[slot]
            bonuses["attack"] += item.get("attack_bonus", 0)
            bonuses["defense"] += item.get("defense_bonus", 0)
    
    return bonuses
```

**Paso 2**: Integrar en GameManager

```gdscript
# En game_manager.gd
var player_equipment: Equipment = Equipment.new()

func get_effective_stats() -> Dictionary:
    var base_stats = {
        "attack": 10 + player_data["level"] * 2,
        "defense": 5 + player_data["level"]
    }
    
    var bonuses = player_equipment.get_stat_bonuses()
    
    return {
        "attack": base_stats["attack"] + bonuses["attack"],
        "defense": base_stats["defense"] + bonuses["defense"]
    }
```

---

### EJEMPLO 5: Sistema de Efectos Especiales

**Paso 1**: Estados de batalla

```gdscript
# En battle_character.gd
var status_effects: Array = []

class StatusEffect:
    var effect_type: String  # "poison", "stun", "slow", etc.
    var duration: int = 0
    var potency: float = 1.0
    
    func _init(type: String, dur: int, pot: float = 1.0) -> void:
        effect_type = type
        duration = dur
        potency = pot

func apply_status_effect(effect: StatusEffect) -> void:
    status_effects.append(effect)
    print("[BattleChar] %s afectado por %s" % [character_type, effect.effect_type])

func process_status_effects(target: BattleCharacter) -> int:
    var additional_damage = 0
    
    for effect in status_effects:
        match effect.effect_type:
            "poison":
                additional_damage += 5 * int(effect.potency)
            "burn":
                additional_damage += 8 * int(effect.potency)
        
        effect.duration -= 1
    
    # Limpiar efectos expirados
    status_effects = status_effects.filter(func(e): return e.duration > 0)
    
    return additional_damage

func calculate_damage(target: BattleCharacter) -> int:
    var base_damage = attack - (target.defense * target.defense_multiplier)
    var variation = randi() % (base_damage / 4)
    var total_damage = max(1, base_damage + variation)
    
    # Agregar daño adicional de efectos
    total_damage += process_status_effects(target)
    
    return total_damage
```

---

### EJEMPLO 6: Sistema de NPCs y Diálogos

**Paso 1**: Crear sistema de NPCs

```gdscript
# En res://src/systems/npc.gd
class_name NPC
extends CharacterBody2D

@export var npc_name: String = "NPC"
@export var dialogue_key: String = "npc_default"

@onready var sprite = $AnimatedSprite2D
@onready var dialogue_area = $DialogueArea

var can_interact: bool = false

func _ready() -> void:
    add_to_group("npc")
    
    if dialogue_area.has_signal("area_entered"):
        dialogue_area.area_entered.connect(_on_dialogue_area_entered)
    if dialogue_area.has_signal("area_exited"):
        dialogue_area.area_exited.connect(_on_dialogue_area_exited)

func _on_dialogue_area_entered(area: Area2D) -> void:
    if area.get_parent().is_in_group("player"):
        can_interact = true
        print("[NPC] ¡Presiona E para hablar con %s!" % npc_name)

func _on_dialogue_area_exited(area: Area2D) -> void:
    if area.get_parent().is_in_group("player"):
        can_interact = false

func start_dialogue() -> void:
    print("[NPC] Iniciando diálogo: %s" % dialogue_key)
    # TODO: Llamar a DialogueManager
```

**Paso 2**: Crear DialogueManager

```gdscript
# En res://src/managers/dialogue_manager.gd
class_name DialogueManager
extends Node

var dialogues: Dictionary = {
    "npc_default": [
        "¡Hola, aventurero!",
        "¿Cómo estás?",
        "¡Buena suerte en tu aventura!"
    ],
    "npc_merchant": [
        "Bienvenido a mi tienda",
        "¿Deseas comprar algo?"
    ]
}

var current_dialogue_index: int = 0
var current_dialogue_key: String = ""

signal dialogue_started
signal dialogue_finished
signal dialogue_line_shown(text: String)

func show_dialogue(key: String) -> void:
    if key not in dialogues:
        push_error("Diálogo no encontrado: %s" % key)
        return
    
    current_dialogue_key = key
    current_dialogue_index = 0
    dialogue_started.emit()
    
    _show_next_line()

func _show_next_line() -> void:
    var lines = dialogues[current_dialogue_key]
    
    if current_dialogue_index >= lines.size():
        dialogue_finished.emit()
        return
    
    var line = lines[current_dialogue_index]
    dialogue_line_shown.emit(line)
    current_dialogue_index += 1
```

---

### EJEMPLO 7: Boss Fight con Patrón Especial

**Paso 1**: Crear clase de Boss

```gdscript
# En res://src/characters/enemy/boss_controller.gd
class_name BossController
extends EnemyController

@export var boss_name: String = "Boss"
@export var special_attack_interval: int = 3
@export var phase_health_threshold: float = 0.5

var turn_count: int = 0
var current_phase: int = 1

func trigger_encounter() -> void:
    var boss_data = {
        "type": boss_name,
        "level": level + 3,
        "health": health * 2,
        "max_health": health * 2,
        "is_boss": true,
        "special_ability": "meteor_strike"
    }
    
    GameManager.start_encounter([boss_data], level + 2)

func get_special_attack() -> Dictionary:
    match turn_count % special_attack_interval:
        0:
            return {
                "name": "Meteor Strike",
                "damage": health * 0.2,  # 20% de su salud como daño
                "affects_all": true
            }
        1:
            return {
                "name": "Heal",
                "healing": health * 0.15,
                "affects_self": true
            }
    
    return {}
```

**Paso 2**: Integrar en BattleController

```gdscript
# En battle_controller.gd
func _execute_enemy_turns() -> void:
    for enemy in enemy_characters:
        if enemy.is_defeated():
            continue
        
        var damage = enemy.calculate_damage(player_character)
        
        # Boss especial
        if enemy.get("is_boss", false):
            var special = enemy.get_special_attack()
            if special:
                damage = special.get("damage", damage)
                print("[Battle] Boss usa: %s!" % special["name"])
        
        player_character.take_damage(damage)
        
        if battle_ui:
            battle_ui.show_player_damage(damage)
        
        await get_tree().create_timer(0.3).timeout
```

---

### EJEMPLO 8: Sistema de Guardado/Cargado Completo

**Paso 1**: Crear SaveManager

```gdscript
# En res://src/managers/save_manager.gd
class_name SaveManager
extends Node

const SAVE_FILE_PATH = "user://saves/"
const SAVE_FILE_NAME = "save_%d.dat"

func save_game(slot: int) -> bool:
    var save_data = {
        "player": GameManager.player_data.duplicate(),
        "inventory": GameManager.inventory.duplicate(),
        "equipment": GameManager.player_equipment.slots.duplicate(),
        "timestamp": Time.get_ticks_msec(),
        "playtime": get_playtime()
    }
    
    var save_path = SAVE_FILE_PATH + SAVE_FILE_NAME % slot
    
    # Crear directorio si no existe
    if not DirAccess.exists(SAVE_FILE_PATH):
        DirAccess.make_absolute_path(SAVE_FILE_PATH)
    
    # Guardar como JSON
    var json_string = JSON.stringify(save_data)
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    file.store_string(json_string)
    
    print("[SaveManager] Guardado en slot %d" % slot)
    return true

func load_game(slot: int) -> bool:
    var save_path = SAVE_FILE_PATH + SAVE_FILE_NAME % slot
    
    if not ResourceLoader.exists(save_path):
        print("[SaveManager] Archivo no encontrado: %s" % save_path)
        return false
    
    var file = FileAccess.open(save_path, FileAccess.READ)
    var json_string = file.get_as_text()
    var save_data = JSON.parse_string(json_string)
    
    # Restaurar datos
    GameManager.player_data = save_data["player"]
    GameManager.inventory = save_data["inventory"]
    
    print("[SaveManager] Cargado desde slot %d" % slot)
    return true

func get_playtime() -> float:
    # TODO: Implementar tracking de tiempo de juego
    return 0.0
```

**Paso 2**: Usar en menú

```gdscript
# Guardar
var save_manager = get_node("/root/SaveManager")
save_manager.save_game(1)

# Cargar
save_manager.load_game(1)
```

---

## 🎯 Tips de Extensión

1. **Mantener sistemas desacoplados**: Usa Signals para comunicación
2. **Usar enums para estados**: Evita strings mágicos
3. **Documentar con ##**: Ayuda a futuros desarrolladores
4. **Probar transiciones**: Asegurarse que los datos se preservan
5. **Usar tipos fuertemente tipados**: `var x: int` en lugar de `var x`

---

**¿Necesitas ayuda con una extensión específica? Consulta el código base en `src/`**
