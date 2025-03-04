

describe 'IIS' {
    context 'Windows features' {
        it 'Installs the Web-Server Windows Feature' {
            $parameters = @{
                ComputerName = 'fileserver01'
                Name = 'fileserver01'
            }
        }
    }
}