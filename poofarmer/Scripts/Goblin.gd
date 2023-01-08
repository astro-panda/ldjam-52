extends KinematicBody2D
class_name Goblin

# Declare member variables here. Examples:
export var speed = 1500
onready var silo = get_tree().get_nodes_in_group("silo")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]
var playerNearby = false
var playerHasPoo = false
var currentPooTargets = []
var health = 5
var stealAmount = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	currentPooTargets.append(silo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2()
	if playerNearby && playerHasPoo:
		velocity = (player.position - position).normalized() * speed * delta
		velocity = move_and_slide(velocity)
	elif currentPooTargets.size() != 0:
		if currentPooTargets.size() > 2:
			print("here")
		velocity = (currentPooTargets.front().position - position).normalized() * speed * delta
		velocity = move_and_slide(velocity)
	else:
		velocity = (silo.position - position).normalized() * speed * delta
		velocity = move_and_slide(velocity)
		
	if velocity.x > 0:
		$AnimatedSprite.animation = "right"
	elif velocity.x < 0:
		$AnimatedSprite.animation = "left"
	elif velocity.y > 0:
		$AnimatedSprite.animation = "down"
	elif velocity.y < 0:
		$AnimatedSprite.animation = "up"


func _on_Visibility_area_entered(area):
	if (area.is_in_group("poo")):
		currentPooTargets.insert(currentPooTargets.find(silo) - 1, area)
	if (area.is_in_group("player")):
		playerHasPoo = player.currentHoldAmount > 0
		playerNearby = true

func _on_Visibility_area_exited(area):
	playerNearby = false
	$StealTimer.stop()
	
func _on_PooPickupDetection_area_entered(area):
	removePooFromTargets(area, true)
		
func removePooFromTargets(poo, destroy):
	if (poo.is_in_group("poo")):
		var pooInstance = poo as Poo
		currentPooTargets.erase(poo)
		if (destroy):
			pooInstance.destroy()

func start_StealTimer():
	$StealTimer.start()

func _on_StealTimer_timeout():
	player.steal_poo(stealAmount)
	if(player.currentHoldAmount == 0):
		playerNearby = false
