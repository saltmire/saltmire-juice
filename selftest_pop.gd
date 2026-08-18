extends SceneTree
## Prova do bug relatado por Scoremonger (itch, 27/07/2026) e da correção.
## Rode:  godot --headless --script selftest_pop.gd
##
## O cenário dele, ao pé da letra: chamar pop() de novo ANTES de a animação
## anterior terminar (mouse sai do botão e volta). Duas coisas tinham que
## quebrar, e este arquivo mede as duas separadamente:
##   1. o tween antigo continuava vivo brigando pelo mesmo property
##   2. `node.scale` no meio da animação virava o novo "base" -> a escala
##      inflava para sempre e o nó nunca voltava ao tamanho real
##
## O teste NÃO confia em "parece certo": ele compara a escala final com a
## escala de repouso original, que é o único número que importa.

var _falhas := 0


func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  ok  ", msg)
	else:
		print("  FALHOU  ", msg)
		_falhas += 1


func _init() -> void:
	var juice: Node = load("res://addons/saltmire_juice/juice.gd").new()
	root.add_child(juice)

	var n := Node2D.new()
	root.add_child(n)
	var repouso := Vector2(1, 1)
	n.scale = repouso

	print("\n--- pop() interrompido 5x no meio (o caso do usuario) ---")
	# [CORRECAO DO TESTE] A 1a versao exigia que a escala fosse EXATAMENTE 1.25x
	# ao fim do laco. Errado: depois de 2 frames o tween ja andou, entao 1.173 e o
	# esperado. O que prova a ausencia de deriva e o PICO nunca passar de 1.25x —
	# com o bug antigo ele chegaria a 1.25^5 = 3.05x.
	var pico := 0.0
	for i in 5:
		juice.pop(n, 1.25, 0.5)          # duracao longa, como ele descreveu
		pico = maxf(pico, n.scale.x)     # medido logo apos disparar: o topo do pulo
		await process_frame
		await process_frame              # interrompe MUITO antes de terminar

	print("    maior escala vista em 5 pops: %.4f (repouso %.4f)" % [pico, repouso.x])
	_ok(pico <= repouso.x * 1.25 + 0.0001,
		"nao inflou: pico ficou em 1.25x; com o bug seria 1.25^5 = %.2fx" % pow(1.25, 5))

	# deixa a ultima animacao terminar de verdade
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 900:
		await process_frame

	print("    escala apos terminar: %.4f" % n.scale.x)
	_ok(n.scale.is_equal_approx(repouso),
		"voltou EXATAMENTE ao repouso (%.4f)" % repouso.x)

	print("\n--- flash() com modulate proprio (bug irmao, nao relatado) ---")
	var c := Sprite2D.new()
	root.add_child(c)
	var cor_propria := Color(0.2, 0.6, 1.0, 1.0)   # azul, NAO branco
	c.modulate = cor_propria
	juice.flash(c, Color(4, 4, 4, 1), 0.15)
	var t1 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t1 < 500:
		await process_frame
	print("    modulate final: %s (era %s)" % [c.modulate, cor_propria])
	_ok(c.modulate.is_equal_approx(cor_propria),
		"voltou a cor DO NO, nao ao branco assumido")

	print("\n--- vazamento: o dicionario esvazia? ---")
	_ok(juice._pops.is_empty(), "_pops vazio apos as animacoes terminarem")
	_ok(juice._flashes.is_empty(), "_flashes vazio apos as animacoes terminarem")

	print("\nSELFTEST %s" % ("PASS" if _falhas == 0 else "FAIL (%d)" % _falhas))
	quit(_falhas)
