require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['sinensup'], table: 'CRONOGRAMAS', exclude: true do
  field 'id_cron_cronograma', map: 'ID'
  field 'id_cron_fecha_cronograma', map: 'fecha_cronograma'
  field 'id_cron_periodo', map: 'periodo'
  field 'id_cron_tipo_entrega', map: 'tipo_entrega'
  field 'id_cron_estado_cronograma', map: 'estado',
    reject_unless: 'Habilitado'
end

datos =
transform datos do
  field 'id_cron_fecha_cronograma', id_cron_fecha_cronograma.gsub('-', '')
  new_field 'cd_cron_cronograma', 'vacío'
  new_field 'ds_cron_cronograma', 'vacío'
end

load datos, to: bases['panel'], table: 'lk_cron_cronograma', append: false
