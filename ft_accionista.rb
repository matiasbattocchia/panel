require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Accionistas', exclude: true do

# ft_accionista

  field 'AccID',
    type: Integer, reject_if: nil
  field 'AccionistasID',
    type: Integer, reject_if: nil
  field 'id_com_compania', map: 'CiaId',
    type: Integer, reject_if: nil
  field 'id_acc_personaria', map: 'Personeria_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'id_acc_pais_inversor', map: 'Inversor_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'i_acc_cant_acciones', map: 'Cant_Acciones_Susc',
    type_default: Integer
  field 'i_acc_porc_participacion', map: 'Participacion',
    type_default: Float

# lk_acc_accionista

  field 'ds_acc_accionista', map: 'Nombre_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_acc_direccion', map: 'Domicilio_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
end

# alemania
# agentina
# australia
# bahamas
# barbados
# bermuda
# brasil
# chile
# españa
# estados unidos
# francia
# holanda
# inglaterra
# islas caiman
# israel
# italia
# luxemburgo
# mexico
# panama
# sin registrar
# suiza
# uruguay
# venezuela

mapa_accionistas = Hash.new(0)

datos.each do |fila|
  id_compania = fila[:id_com_compania]
  id_accionistas = fila[:AccionistasID]

  if mapa_accionistas[id_compania] < id_accionistas
    mapa_accionistas[id_compania] = id_accionistas
  end
end

datos.select! do |fila|
  fila[:AccionistasID] == mapa_accionistas[fila[:id_com_compania]]
end

personas =
extract from: bases['panel'], table: 'lk_acc_accionista'
# transform datos, unique: 'ds_acc_accionista', exclude: true do
#   field 'ds_acc_accionista'
#   field 'ds_acc_direccion'
#   new_field 'id_acc_accionista', row_number
#   new_field 'ds_acc_pais', id_acc_pais_inversor
#   new_field 'cd_acc_accionista', 0
# end

mapa_personas = Hash.new

personas.each do |persona|
  mapa_personas[persona[:ds_acc_accionista]] = persona[:id_acc_accionista]
end

accionistas =
transform datos, exclude: true do
  field 'id_com_compania'
  field 'id_acc_personaria'
  field 'id_acc_pais_inversor'
  field 'i_acc_cant_acciones'
  field 'i_acc_porc_participacion'
  new_field 'id_acc_accionista', mapa_personas[ds_acc_accionista]
  new_field 'id_acc_fecha_desde', '2013-12-06'
  new_field 'id_acc_fecha_hasta', '2013-12-06'
  new_field 'i_acc_cant_acciones_suscrip', -1
end

#load personas, to: bases['panel'], table: 'lk_acc_accionista', append: false
load accionistas, to: bases['panel'], table: 'ft_accionista', append: false
