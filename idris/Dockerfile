FROM dgellow/idris

RUN apt-get update

RUN apt-get install -y apt-utils

RUN apt-get install -y make curl wget tmux ruby vim && \
    apt-get autoremove -y

RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

RUN curl -LSso /usr/local/bin/vim-bundle https://raw.githubusercontent.com/benmills/vim-bundle/master/vim-bundle && \
    chmod +x /usr/local/bin/vim-bundle && \
    vim-bundle install benmills/vimux

RUN cd ~/.vim/bundle && \
    git clone --depth=1 https://github.com/idris-hackers/idris-vim.git

RUN cd ~/.vim/bundle && \
    git clone --depth=1 https://github.com/vim-syntastic/syntastic.git

COPY idris.vimrc /root/.vimrc

