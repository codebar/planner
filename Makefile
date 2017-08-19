run:
	bundle exec rails server
test: 
	bundle exec rake
create-database:
	bundle exec rake db:create
migrate-database:
	bundle exec rake db:migrate db:test:prepare
seed-database:
	bundle exec rake db:seed
backup_production:
	heroku pgbackups:capture --app=codebar-production
	curl -o pg-production-latest.dump `heroku pgbackups:url --app=codebar-production`
	bzip2 pg-production-latest.dump
deploy_production:
	git pull -r -X ours production master
	heroku maintenance:on --app=codebar-production
	git tag production_release_`date +"%Y%m%d-%H%M%S"`
	git push upstream --tags
	git push production master
	heroku run rake db:migrate --app=codebar-production
	heroku maintenance:off --app=codebar-production
backup_staging:
	heroku pgbackups:capture --app=codebar-staging
	curl -o pg-staging-latest.dump `heroku pgbackups:url --app=codebar-staging`
	bzip2 pg-staging-latest.dump
deploy_staging:
	git pull -r -X ours staging master
	heroku maintenance:on --app=codebar-staging
	git tag staging_release_`date +"%Y%m%d-%H%M%S"`
	git push upstream --tags
	git push staging master
	heroku run rake db:migrate --app=codebar-staging
	heroku maintenance:off --app=codebar-staging
