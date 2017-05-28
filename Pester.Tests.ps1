Describe "This is a group of Tests" 
{
    Context "A set of tests allowing us to group them and have scope" {
        It "This is a test that passes" {
            'value' | Should BeExactly 'value'
        }
        It "This is a test that fails" {
            'What I am' | Should Be 'What is expected'
        }
    }
}