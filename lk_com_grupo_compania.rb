require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Grupos', exclude: true do
  field 'id_com_grupo_compania', map: 'GrupoId', type: Integer
  field 'ds_com_grupo_compania', map: 'Denominacion', strip: true, reject_if: 'No informado'
end

datos =
transform datos do
  new_field 'cd_com_grupo_compania', 'vacío'
end

load datos, to: bases['panel'], table: 'lk_com_grupo_compania', append: false
