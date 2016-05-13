
module SetupWorker # mix-in

  module_function

  def read(manifests)
    dojo.runner.runnable(manifests).map { |manifest| manifest.display_name }.sort
  end

  def read_instructions
    names = []
    instructions_hash =  {}
    instructions.each do |instruction|
      names << instruction.name
      instructions_hash[instruction.name] = instruction.text
    end
    [names.sort, instructions_hash]
  end

end
