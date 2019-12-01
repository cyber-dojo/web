FROM cyberdojo/web-base:63adedc
LABEL maintainer=jon@jaggersoft.com

WORKDIR /cyber-dojo
COPY . .
RUN chown -R nobody:nogroup .

# NB: should be able to replace the above 2 lines with
# COPY --chown=nobody:nogroup . .
# but it currently causes a failure...
# /usr/lib/ruby/2.5.0/fileutils.rb:232:in `mkdir': Permission denied @ dir_s_mkdir - /cyber-dojo/tmp (Errno::EACCES)

ARG SHA
ENV SHA=${SHA}

EXPOSE  3000
USER nobody
CMD [ "./up.sh" ]
