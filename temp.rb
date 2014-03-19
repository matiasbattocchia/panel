require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

coberturas =
extract from: bases['panel'], table: 'lk_tie_trimestre', exclude: true do
  field :id, map: 'id_tie_trimestre'
  field :ds, map: 'ds_tie_trimestre'
  field :anio, map: 'id_tie_anio'
end

raw coberturas, to: bases['panel'] do
  query "UPDATE lk_tie_trimestre SET ds_tie_trimestre='#{ds} ''#{anio.to_s[-2..-1]}' WHERE id_tie_trimestre=#{id}"
end
