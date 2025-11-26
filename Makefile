start:
	docker compose up -d

restart:
	docker compose restart

stop:
	docker compose down

logs:
	docker compose logs -f

bash:
	docker compose exec jekyll bash
