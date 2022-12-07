from github import Github
import os

def get_files(repo):
    pta_repo = Github().get_repo(repo)
    contents = pta_repo.get_contents("plugins")
    files = []
    while contents:
        file_content = contents.pop(0)
        if file_content.type == "dir":
            contents.extend(pta_repo.get_contents(file_content.path))
        else:
            #  print(file_content)
            files.push(file_content)

    return files

# checks if files_b has entries that files_a does not have
def compare_lists(files_a, files_b):
    for b in files_b:
        for a in files_a:
            if a.name == b.name:
                break
        else:
            print("only in pta", a.name)
                


#  for c in files:
#      print("c:", c.type)

#  github = Github(os.getenv('GITHUB_TOKEN'))
#  repo = github.get_repo("jooooscha/nixvim")

def main():
    pta_files = get_files("pta2002/nixvim")
    me_files = get_files("nixneovim/nixneovim")
    print("done")


if __name__ == "__main__":
    main()
