require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

inversiones =
extract(from: bases['sinensup'], table: 'INV_PLAZOS_FIJOS_RECIBIDOS', exclude: true) do
  field 'id_com_compania', map: 'CIAID',
    type: Integer
  field 'id_tie_mes', map: 'periodo',
    type: Integer
  field 'id_ent_version_rectificativo', map: 'version_rectificativo'
  field 'id_plz_tipo_plazo_fijo', map: 'ID_ssn_tipo_plazo_fijo',
    type: Integer
  field 'id_mon_moneda', map: 'id_ssn_moneda_origen',
    strip: true
  field 'i_plz_valor_contable', map: 'valor_contable'
end

inversiones =
transform inversiones do
  field 'id_mon_moneda', case id_mon_moneda
                         when 'EUE' then 'EUR'
                         when 'BRE' then 'BRL'
                         end
end

begin
  load inversiones, to: bases['panel'], table: 'ft_plazo_fijo', append: false
rescue => e
  p e.message
end
