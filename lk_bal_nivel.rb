require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['sinensup'], table: 'CODIGOS', exclude: true do
  field 'imputable'
  field 'nivel'
  field 'codigo_completo'
  field 'descripcion'
  field 'imputacion_ramo_obligatoria'
end

datos =
transform datos.sort_by! { |row| row[:nivel] }, exclude: true do
  switch nivel
  codigo = codigo_completo.split('.')
  new_field "ds_bal_nivel#{nivel}", descripcion
  new_field "cd_bal_nivel#{nivel}", codigo[nivel - 1]
  new_field "cd_bal_nivel#{nivel}_completo", codigo_completo
  new_field "id_bal_nivel#{nivel}_nfo_compl", 'vacío'
  new_field "id_bal_nivel#{nivel}_ramo_oblig", imputacion_ramo_obligatoria

  nivel.downto(1) do |n|
    new_field "id_bal_nivel#{n}", if n == nivel
                                    count
                                  else
                                    output[n].select{ |row|
                                      row["cd_bal_nivel#{n}".to_sym] == codigo[n - 1]
                                    }.first["id_bal_nivel#{n}".to_sym]
                                  end
  end

  if imputable == 1 && nivel != 8
    row[:nivel] = nivel + 1
    datos << row
  end
end

datos.each do |nivel, datos_nivel|
  load datos_nivel, to: bases['panel'], table: "lk_bal_nivel#{nivel}", append: false
end
