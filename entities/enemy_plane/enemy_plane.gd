class_name EnemyPlane
extends Node3D

const ENEMY = preload("uid://bc1hvnm1xintd")

@onready var sprite_enemy: Sprite3D = %SpriteEnemy

@export var player: PlayerController

func show_sprite() -> void:
	sprite_enemy.show()

func swap_enemy(direction: float) -> void:
	sprite_enemy.hide()
	var enemy: EnemyController = ENEMY.instantiate()
	add_sibling(enemy)
	enemy.global_position = sprite_enemy.global_position
	enemy.jump(direction)
	enemy.player = player
